from __future__ import annotations

import argparse
import gc

import torch
from pathlib import Path

from config import (
    AUDIO_FILE,
    DIARIZATION_DIR,
    OUTPUT_DIR,
    RUN_ALIGNMENT,
    RUN_DIARIZATION,
    RUN_QWEN,
    RUN_SPEECH,
    TRANSCRIPTION_DIR,
)
from audio_utils import convert_to_wav
from dialogue_aligner import align_transcription, save_dialogue_json, save_dialogue_txt
from qwen_pipeline import run_qwen_pipeline
from rttm_parser import parse_rttm
from speaker_diarization import diarize
from speech_to_text import save_transcription_json, save_transcription_txt, transcribe


def release_torch_cache(label: str = "Memory") -> None:
    """Release unused Python objects and the unused PyTorch CUDA cache."""
    gc.collect()
    if torch.cuda.is_available():
        try:
            torch.cuda.synchronize()
            torch.cuda.empty_cache()
        except RuntimeError as exc:
            print(f"[{label}] Очистка CUDA-кэша не удалась: {exc}", flush=True)


def main(audio_path: str | None = None) -> None:
    audio_file = (
        Path(audio_path).expanduser().resolve()
        if audio_path
        else AUDIO_FILE
    )
    print("=" * 68 + "\nCorpAcc-with-MTC — Speech Pipeline\n" + "=" * 68, flush=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    DIARIZATION_DIR.mkdir(parents=True, exist_ok=True)
    TRANSCRIPTION_DIR.mkdir(parents=True, exist_ok=True)

    if not audio_file.exists():
        raise FileNotFoundError(f"Аудиофайл не найден: {audio_file}")

    base_name = audio_file.stem
    wav_file = OUTPUT_DIR / f"{base_name}_16k.wav"
    transcription_json = TRANSCRIPTION_DIR / f"{base_name}.json"
    transcription_txt = TRANSCRIPTION_DIR / f"{base_name}.txt"
    rttm_file = DIARIZATION_DIR / f"{base_name}.rttm"
    dialogue_txt = OUTPUT_DIR / "dialogue.txt"
    dialogue_json = OUTPUT_DIR / "dialogue.json"

    print(f"\n[Input] {audio_file}", flush=True)
    print("\n[1/5] AUDIO", flush=True)
    wav_file = convert_to_wav(audio_file, wav_file)

    transcription = None
    diarization = None
    alignment_result = None
    if RUN_SPEECH:
        print("\n[2/5] WHISPER", flush=True)
        transcription = transcribe(audio_file)
        save_transcription_txt(transcription, transcription_txt)
        save_transcription_json(transcription, transcription_json)
        print("[Memory] Транскрипция сохранена.", flush=True)
        release_torch_cache()

    if RUN_DIARIZATION:
        print("\n[3/5] NEMOTRON DIARIZATION", flush=True)
        diarize(wav_file, rttm_file)
        diarization = parse_rttm(rttm_file)
        speakers = sorted({item["speaker"] for item in diarization})
        print(f"[Diarization] Сегментов: {len(diarization)}; спикеры: {', '.join(speakers)}", flush=True)
        release_torch_cache()

    if RUN_ALIGNMENT:
        print("\n[4/5] ALIGNMENT", flush=True)
        if transcription is None:
            raise RuntimeError("Для alignment нужен результат Whisper (RUN_SPEECH=True).")
        if diarization is None:
            raise RuntimeError("Для alignment нужен результат Nemotron (RUN_DIARIZATION=True).")
        alignment_result = align_transcription(transcription, diarization)
        words = alignment_result["aligned_words"]
        segments = alignment_result["dialogue_segments"]
        unknown = sum(1 for word in words if word.get("speaker") is None)
        print(f"[Alignment] Слов: {len(words)}; реплик: {len(segments)}; UNKNOWN слов: {unknown}", flush=True)
        save_dialogue_txt(segments, dialogue_txt)
        save_dialogue_json(dialogue_json, audio_file, transcription, diarization, words, segments)
        # Drop model results only after alignment and dialogue.json have been saved.
        transcription = None
        diarization = None
        alignment_result = None
        del words, segments
        release_torch_cache()

    if RUN_QWEN:
        print("\n[5/5] QWEN — extraction and summary", flush=True)
        if not dialogue_json.exists():
            raise RuntimeError("Для Qwen нужен output/dialogue.json. Включи RUN_ALIGNMENT.")
        # Nemo runs as a separate CLI process; when it has exited, its process VRAM is released.
        # Whisper must not be held as a global model inside speech_to_text.py.
        release_torch_cache()
        run_qwen_pipeline(dialogue_json)
        release_torch_cache()

    print("\n" + "=" * 68 + "\nГОТОВО\n" + "=" * 68, flush=True)
    print(f"Whisper TXT: {transcription_txt}")
    print(f"Whisper JSON: {transcription_json}")
    print(f"RTTM: {rttm_file}")
    print(f"Dialogue TXT: {dialogue_txt}")
    print(f"Dialogue JSON (технический вход для Qwen): {dialogue_json}")
    if RUN_QWEN:
        print(f"Qwen dialogue TXT: {OUTPUT_DIR / 'qwen' / 'dialogue.txt'}")
        print(f"Qwen context JSON: {OUTPUT_DIR / 'qwen' / 'context.json'}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Local audio transcription, speaker diarization and Qwen context extraction."
    )
    parser.add_argument(
        "audio",
        nargs="?",
        help="Path to the audio file. If omitted, uses input/test_6.mp3.",
    )
    arguments = parser.parse_args()
    main(arguments.audio)
