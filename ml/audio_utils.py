import subprocess
from pathlib import Path

from config import SAMPLE_RATE, CHANNELS


def convert_to_wav(
    input_file: Path,
    output_file: Path,
  
):
    """
    Конвертирует исходное аудио в:

    - WAV
    - mono
    - 16 kHz
    - PCM 16-bit

    Это формат, который удобно использовать для NeMo-Speech.cpp.
    """

    output_file.parent.mkdir(parents=True, exist_ok=True)

    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(input_file),
        "-ac",
        str(CHANNELS),
        "-ar",
        str(SAMPLE_RATE),
        "-sample_fmt",
        "s16",
        str(output_file),
    ]

    print("\n[Audio] Конвертация аудио:")
    print(" ".join(command))

    result = subprocess.run(
    command,
    capture_output=True,
    text=True,
    encoding="utf-8",
    errors="replace",
    )

    print(result.stdout)

    if result.returncode != 0:
        raise RuntimeError(
            "FFmpeg завершился с ошибкой."
        )

    if not output_file.exists():
        raise RuntimeError(
            f"WAV-файл не был создан: {output_file}"
        )

    print(f"[Audio] Готово: {output_file}")

    return output_file