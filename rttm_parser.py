from pathlib import Path


def normalize_speaker_name(
    speaker: str,
) -> str:

    speaker = speaker.strip()

    if speaker.lower().startswith("speaker_"):

        number = speaker.split("_")[-1]

        try:
            number_int = int(number)

            return f"SPEAKER_{number_int}"

        except ValueError:
            pass

    return speaker.upper()


def parse_rttm(
    rttm_file: Path,
):
    segments = []

    with open(
        rttm_file,
        "r",
        encoding="utf-8",
    ) as file:

        for line in file:

            line = line.strip()

            if not line:
                continue

            parts = line.split()

            if len(parts) < 8:
                continue

            if parts[0] != "SPEAKER":
                continue

            start = float(parts[3])
            duration = float(parts[4])

            speaker = normalize_speaker_name(
                parts[7]
            )

            segments.append(
                {
                    "start": start,
                    "end": start + duration,
                    "duration": duration,
                    "speaker": speaker,
                }
            )

    segments.sort(
        key=lambda x: (
            x["start"],
            x["end"],
        )
    )

    return segments