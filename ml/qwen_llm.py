from __future__ import annotations

import gc
import json
import time
from typing import Any

import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    StoppingCriteria,
    StoppingCriteriaList,
)

from config import QWEN_4BIT, QWEN_COMPUTE_DTYPE, QWEN_MODEL_CANDIDATES, QWEN_MAX_NEW_TOKENS


class _GenerationProgress(StoppingCriteria):
    """Print periodic progress; always returns False so it never stops generation."""

    def __init__(self, prompt_length: int, interval: int = 25) -> None:
        self.prompt_length = prompt_length
        self.interval = interval
        self.next_report = interval

    def __call__(self, input_ids, scores, **kwargs) -> bool:
        generated = int(input_ids.shape[-1] - self.prompt_length)
        if generated >= self.next_report:
            print(f"[Qwen] Сгенерировано токенов: {generated}", flush=True)
            self.next_report = generated + self.interval
        return False


def _has_weights(model_dir) -> bool:
    return (
        model_dir.is_dir()
        and (model_dir / "config.json").is_file()
        and (
            (model_dir / "model.safetensors").is_file()
            or any(model_dir.glob("model-*.safetensors"))
            or (model_dir / "pytorch_model.bin").is_file()
            or any(model_dir.glob("pytorch_model-*.bin"))
        )
    )


def resolve_model_dir():
    for candidate in QWEN_MODEL_CANDIDATES:
        if _has_weights(candidate):
            return candidate
    checked = "\n".join(str(path) for path in QWEN_MODEL_CANDIDATES)
    raise FileNotFoundError(
        "Не найдены локальные веса Qwen для Transformers. Проверены папки:\n"
        + checked
        + "\nУбедись, что скачаны config.json, tokenizer и все части модели."
    )


class QwenTransformers:
    """Direct in-process Qwen inference with Transformers; no server or llama.cpp."""

    def __init__(self) -> None:
        if not torch.cuda.is_available():
            raise RuntimeError("CUDA недоступна. Qwen не будет загружена на CPU.")

        self.model = None
        self.tokenizer = None
        self.model_dir = resolve_model_dir()
        print(f"[Qwen] Локальная модель: {self.model_dir}", flush=True)

        self.tokenizer = AutoTokenizer.from_pretrained(
            str(self.model_dir),
            local_files_only=True,
            use_fast=True,
        )

        quantization_config = None
        if QWEN_4BIT:
            compute_dtype = (
                torch.float16 if QWEN_COMPUTE_DTYPE == "float16" else torch.bfloat16
            )
            quantization_config = BitsAndBytesConfig(
                load_in_4bit=True,
                bnb_4bit_quant_type="nf4",
                bnb_4bit_use_double_quant=True,
                bnb_4bit_compute_dtype=compute_dtype,
            )

        print("[Qwen] Загрузка модели...", flush=True)
        kwargs: dict[str, Any] = {
            "device_map": {"": 0},
            "low_cpu_mem_usage": True,
            "local_files_only": True,
            "attn_implementation": "sdpa",
        }
        if quantization_config is not None:
            kwargs["quantization_config"] = quantization_config
        else:
            kwargs["dtype"] = torch.float16

        self.model = AutoModelForCausalLM.from_pretrained(
            str(self.model_dir),
            **kwargs,
        )
        self.model.eval()
        print(
            f"[Qwen] Готова. Устройство: "
            f"{self.model.get_input_embeddings().weight.device}; "
            f"VRAM allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GiB",
            flush=True,
        )

    @staticmethod
    def _parse_json(text: str) -> dict[str, Any]:
        decoder = json.JSONDecoder()
        for index, char in enumerate(text):
            if char != "{":
                continue
            try:
                value, _ = decoder.raw_decode(text[index:])
            except json.JSONDecodeError:
                continue
            if isinstance(value, dict):
                return value
        raise RuntimeError(
            "Qwen не вернула корректный JSON. Ответ модели:\n" + text[:2500]
        )

    def chat_json(
        self,
        messages: list[dict[str, str]],
        schema: dict[str, Any],
        max_tokens: int | None = None,
    ) -> dict[str, Any]:
        if self.model is None or self.tokenizer is None:
            raise RuntimeError("Модель Qwen уже выгружена.")

        prepared = [dict(message) for message in messages]
        schema_text = json.dumps(schema, ensure_ascii=False, separators=(",", ":"))
        instruction = (
            "Верни ровно один JSON-объект, без Markdown и пояснений. "
            "Соблюдай поля и типы схемы, не добавляй поля. "
            "Если данных нет, используй пустые значения соответствующего типа.\n"
            "Схема JSON: " + schema_text
        )
        system_index = next(
            (i for i, item in enumerate(prepared) if item.get("role") == "system"),
            None,
        )
        if system_index is None:
            prepared.insert(0, {"role": "system", "content": instruction})
        else:
            prepared[system_index]["content"] += "\n\n" + instruction

        token_start = time.perf_counter()
        template_kwargs: dict[str, Any] = {
            "tokenize": True,
            "add_generation_prompt": True,
            "return_tensors": "pt",
            "return_dict": True,
        }
        if getattr(self.model.config, "model_type", "") == "qwen3":
            template_kwargs["enable_thinking"] = False

        inputs = self.tokenizer.apply_chat_template(prepared, **template_kwargs)
        prompt_length = int(inputs["input_ids"].shape[1])
        device = self.model.get_input_embeddings().weight.device
        inputs = {key: value.to(device) for key, value in inputs.items()}
        print(
            f"[Qwen] Вход: {prompt_length} токенов; "
            f"лимит ответа: {max_tokens or QWEN_MAX_NEW_TOKENS}; "
            f"подготовка: {time.perf_counter() - token_start:.1f} сек.",
            flush=True,
        )

        output = None
        new_tokens = None
        try:
            torch.cuda.synchronize()
            torch.cuda.reset_peak_memory_stats()
            started = time.perf_counter()
            with torch.inference_mode():
                output = self.model.generate(
                    **inputs,
                    max_new_tokens=max_tokens or QWEN_MAX_NEW_TOKENS,
                    do_sample=False,
                    use_cache=True,
                    num_beams=1,
                    pad_token_id=self.tokenizer.eos_token_id,
                    stopping_criteria=StoppingCriteriaList([
                        _GenerationProgress(prompt_length, interval=25)
                    ]),
                )
            torch.cuda.synchronize()
            elapsed = time.perf_counter() - started
            count = int(output.shape[1] - prompt_length)
            print(
                f"[Qwen] Выход: {count} токенов за {elapsed:.1f} сек. "
                f"({count / elapsed if elapsed else 0:.2f} токенов/сек)",
                flush=True,
            )
            print(
                f"[Qwen] VRAM allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GiB; "
                f"reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GiB; "
                f"peak: {torch.cuda.max_memory_allocated() / 1024**3:.2f} GiB",
                flush=True,
            )
            new_tokens = output[0, prompt_length:]
            answer = self.tokenizer.decode(
                new_tokens,
                skip_special_tokens=True,
            ).strip()
        finally:
            del inputs
            if new_tokens is not None:
                del new_tokens
            if output is not None:
                del output
            gc.collect()
            if torch.cuda.is_available():
                torch.cuda.empty_cache()

        return self._parse_json(answer)

    def close(self) -> None:
        """Drop model references and clear unused CUDA cache."""
        model = self.model
        tokenizer = self.tokenizer
        self.model = None
        self.tokenizer = None
        if torch.cuda.is_available():
            torch.cuda.synchronize()
        del model, tokenizer
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
            torch.cuda.synchronize()
        print("[Qwen] Модель выгружена.", flush=True)
