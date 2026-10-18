import subprocess
from pathlib import Path

from config import (
    NEMO_SPEECH,
    DIARIZATION_MODEL,
    DIARIZATION_DEVICE,
    DIARIZATION_PRESET,
    DIARIZATION_ONSET,
    DIARIZATION_OFFSET,
    PAD_ONSET,
    PAD_OFFSET,
    MIN_DURATION_ON,
    MIN_DURATION_OFF,
)


def diarize(
    audio_file: Path,
    output_file: Path,
):
    output_file.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    if not NEMO_SPEECH.exists():
        raise FileNotFoundError(
            f"nemo-speech.exe не найден:\n{NEMO_SPEECH}"
        )

    command = [
        str(NEMO_SPEECH),
        "diarize",
        str(audio_file),
        "--device",
        DIARIZATION_DEVICE,
        "--model",
        DIARIZATION_MODEL,
        "--preset",
        DIARIZATION_PRESET,
        "--format",
        "rttm",
        "--output",
        str(output_file),
        "--force",
    ]

    optional_arguments = [
        ("--onset", DIARIZATION_ONSET),
        ("--offset", DIARIZATION_OFFSET),
        ("--pad-onset", PAD_ONSET),
        ("--pad-offset", PAD_OFFSET),
        ("--min-duration-on", MIN_DURATION_ON),
        ("--min-duration-off", MIN_DURATION_OFF),
    ]

    for argument, value in optional_arguments:

        if value is not None:
            command.extend(
                [
                    argument,
                    str(value),
                ]
            )

    print("\n[Diarization] Запуск Nemotron:")
    print(
        " ".join(
            str(item)
            for item in command
        )
    )

    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    print(result.stdout)

    if result.returncode != 0:
        raise RuntimeError(
            "NeMo diarization завершился "
            f"с кодом {result.returncode}"
        )

    if not output_file.exists():
        raise RuntimeError(
            f"RTTM не был создан: {output_file}"
        )

    print(
        f"[Diarization] Результат: {output_file}"
    )

    return output_file