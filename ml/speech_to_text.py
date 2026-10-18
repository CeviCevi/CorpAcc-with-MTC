import json
import os
from pathlib import Path
from typing import Any


# ============================================================
# CUDA DLL FIX
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent

SITE_PACKAGES = (
    PROJECT_ROOT
    / ".venv"
    / "Lib"
    / "site-packages"
)


def add_cuda_dll_directory(path: Path):
    if not path.exists():
        return

    try:
        os.add_dll_directory(
            str(path)
        )
    except Exception:
        pass

    current_path = os.environ.get(
        "PATH",
        ""
    )

    path_str = str(path)

    existing_paths = current_path.split(
        os.pathsep
    )

    if path_str not in existing_paths:

        os.environ["PATH"] = (
            path_str
            + os.pathsep
            + current_path
        )


add_cuda_dll_directory(
    SITE_PACKAGES
    / "nvidia"
    / "cublas"
    / "bin"
)

add_cuda_dll_directory(
    SITE_PACKAGES
    / "nvidia"
    / "cuda_nvrtc"
    / "bin"
)

add_cuda_dll_directory(
    SITE_PACKAGES
    / "nvidia"
    / "cudnn"
    / "bin"
)

add_cuda_dll_directory(
    SITE_PACKAGES
    / "nvidia"
    / "cuda_runtime"
    / "bin"
)

add_cuda_dll_directory(
    SITE_PACKAGES
    / "torch"
    / "lib"
)


# ============================================================
# IMPORT
# ============================================================

from faster_whisper import WhisperModel

from config import (
    WHISPER_MODEL,
    WHISPER_DEVICE,
    WHISPER_COMPUTE_TYPE,
    WHISPER_LANGUAGE,
    WHISPER_MULTILINGUAL,
    WHISPER_TASK,
    WHISPER_BEAM_SIZE,
    WHISPER_VAD_FILTER,
    WHISPER_CONDITION_ON_PREVIOUS_TEXT,
    WHISPER_WORD_TIMESTAMPS,
    WHISPER_LANGUAGE_DETECTION_THRESHOLD,
    WHISPER_LANGUAGE_DETECTION_SEGMENTS,
)


_MODEL = None


# ============================================================
# LOAD MODEL
# ============================================================

def load_model():

    global _MODEL

    if _MODEL is not None:
        return _MODEL

    print()
    print("=" * 70)
    print("[Whisper] Загрузка модели")
    print("=" * 70)

    print(
        f"[Whisper] Model: {WHISPER_MODEL}"
    )

    print(
        f"[Whisper] Device: {WHISPER_DEVICE}"
    )

    print(
        f"[Whisper] Compute type: "
        f"{WHISPER_COMPUTE_TYPE}"
    )

    print(
        f"[Whisper] Language: "
        f"{WHISPER_LANGUAGE}"
    )

    print(
        f"[Whisper] Multilingual: "
        f"{WHISPER_MULTILINGUAL}"
    )

    # --------------------------------------------------------
    # Проверка локальной модели
    # --------------------------------------------------------

    if isinstance(
        WHISPER_MODEL,
        Path,
    ):

        if not WHISPER_MODEL.exists():

            raise FileNotFoundError(
                "Локальная модель Whisper "
                f"не найдена:\n{WHISPER_MODEL}"
            )

        model_source = str(
            WHISPER_MODEL
        )

    else:

        model_source = WHISPER_MODEL

    # --------------------------------------------------------
    # Загрузка
    # --------------------------------------------------------

    _MODEL = WhisperModel(
        model_source,
        device=WHISPER_DEVICE,
        compute_type=WHISPER_COMPUTE_TYPE,
    )

    print(
        "[Whisper] Модель загружена."
    )

    return _MODEL


# ============================================================
# TRANSCRIBE
# ============================================================

def transcribe(
    audio_file: Path,
) -> dict[str, Any]:

    model = load_model()

    print()
    print("=" * 70)
    print("[Whisper] Транскрипция")
    print("=" * 70)

    print(
        f"[Whisper] Audio: {audio_file}"
    )

    # --------------------------------------------------------
    # language=None
    #
    # означает автоматическое определение языка.
    #
    # multilingual=True
    #
    # позволяет делать language detection
    # для каждого сегмента.
    # --------------------------------------------------------

    segments_generator, info = (
        model.transcribe(
            str(audio_file),

            language=WHISPER_LANGUAGE,

            task=WHISPER_TASK,

            beam_size=WHISPER_BEAM_SIZE,

            vad_filter=WHISPER_VAD_FILTER,

            condition_on_previous_text=(
                WHISPER_CONDITION_ON_PREVIOUS_TEXT
            ),

            word_timestamps=(
                WHISPER_WORD_TIMESTAMPS
            ),

            multilingual=(
                WHISPER_MULTILINGUAL
            ),

            language_detection_threshold=(
                WHISPER_LANGUAGE_DETECTION_THRESHOLD
            ),

            language_detection_segments=(
                WHISPER_LANGUAGE_DETECTION_SEGMENTS
            ),
        )
    )

    segments = []

    detected_language = getattr(
        info,
        "language",
        None,
    )

    language_probability = getattr(
        info,
        "language_probability",
        None,
    )

    # --------------------------------------------------------
    # SEGMENTS
    # --------------------------------------------------------

    for segment in segments_generator:

        words = []

        if segment.words is not None:

            for word in segment.words:

                if (
                    word.start is None
                    or word.end is None
                ):
                    continue

                words.append(
                    {
                        "start": float(
                            word.start
                        ),
                        "end": float(
                            word.end
                        ),
                        "word": word.word,
                        "probability": (
                            float(
                                word.probability
                            )
                            if word.probability
                            is not None
                            else None
                        ),
                    }
                )

        segments.append(
            {
                "id": int(
                    segment.id
                ),

                "start": float(
                    segment.start
                ),

                "end": float(
                    segment.end
                ),

                "text": (
                    segment.text.strip()
                ),

                "words": words,
            }
        )

    # --------------------------------------------------------
    # RESULT
    # --------------------------------------------------------

    result = {
        "language_mode": (
            "auto"
            if WHISPER_LANGUAGE is None
            else "fixed"
        ),

        "requested_language": (
            WHISPER_LANGUAGE
        ),

        "detected_language": (
            detected_language
        ),

        "language_probability": (
            float(language_probability)
            if language_probability
            is not None
            else None
        ),

        "multilingual": (
            WHISPER_MULTILINGUAL
        ),

        "task": WHISPER_TASK,

        "segments": segments,
    }

    print()
    print(
        "[Whisper] Результат:"
    )

    print(
        f"  Сегментов: {len(segments)}"
    )

    total_words = sum(
        len(segment["words"])
        for segment in segments
    )

    print(
        f"  Слов с timestamps: "
        f"{total_words}"
    )

    if WHISPER_LANGUAGE is None:

        print(
            "  Режим языка: "
            "АВТОМАТИЧЕСКИЙ"
        )

        if detected_language:

            print(
                f"  Первично обнаружен язык: "
                f"{detected_language}"
            )

            if language_probability is not None:

                print(
                    f"  Вероятность: "
                    f"{language_probability:.3f}"
                )

        print(
            "  Multilingual detection: "
            f"{WHISPER_MULTILINGUAL}"
        )

    else:

        print(
            f"  Фиксированный язык: "
            f"{WHISPER_LANGUAGE}"
        )

    return result


# ============================================================
# SAVE JSON
# ============================================================

def save_transcription_json(
    transcription: dict[str, Any],
    output_file: Path,
):

    output_file.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with open(
        output_file,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            transcription,
            file,
            ensure_ascii=False,
            indent=2,
        )

    print(
        f"[Whisper] JSON сохранён: "
        f"{output_file}"
    )


# ============================================================
# SAVE TXT
# ============================================================

def save_transcription_txt(
    transcription: dict[str, Any],
    output_file: Path,
):

    output_file.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with open(
        output_file,
        "w",
        encoding="utf-8",
    ) as file:

        for segment in transcription[
            "segments"
        ]:

            start = segment["start"]
            end = segment["end"]
            text = segment["text"]

            file.write(
                f"[{format_timestamp(start)} - "
                f"{format_timestamp(end)}] "
                f"{text}\n"
            )

    print(
        f"[Whisper] TXT сохранён: "
        f"{output_file}"
    )


# ============================================================
# TIMESTAMP
# ============================================================

def format_timestamp(
    seconds: float,
) -> str:

    minutes = int(
        seconds // 60
    )

    remaining = (
        seconds
        - minutes * 60
    )

    return (
        f"{minutes:02d}:"
        f"{remaining:05.2f}"
    )