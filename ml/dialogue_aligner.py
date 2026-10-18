import json
import re
from pathlib import Path
from typing import Any

from config import (
    MAX_NEAREST_DISTANCE,
    MAX_SILENCE_BETWEEN_WORDS,
)


# ============================================================
# TEXT
# ============================================================

def clean_joined_text(
    words: list[str],
) -> str:

    if not words:
        return ""

    text = " ".join(
        word.strip()
        for word in words
        if word.strip()
    )

    # Убираем пробел перед пунктуацией.
    text = re.sub(
        r"\s+([,.!?;:%…])",
        r"\1",
        text,
    )

    # Дефис/тире.
    text = re.sub(
        r"\s+([)\]}»])",
        r"\1",
        text,
    )

    # Открывающая пунктуация.
    text = re.sub(
        r"([(\[{«])\s+",
        r"\1",
        text,
    )

    # Нормализуем несколько пробелов.
    text = re.sub(
        r"\s+",
        " ",
        text,
    )

    return text.strip()


# ============================================================
# SPEAKER ASSIGNMENT
# ============================================================

def interval_overlap(
    start_a: float,
    end_a: float,
    start_b: float,
    end_b: float,
) -> float:

    return max(
        0.0,
        min(end_a, end_b)
        - max(start_a, start_b),
    )


def assign_word_to_speaker(
    word: dict[str, Any],
    diarization: list[dict[str, Any]],
) -> tuple[str | None, str]:

    word_start = float(word["start"])
    word_end = float(word["end"])

    word_mid = (
        word_start + word_end
    ) / 2.0

    # --------------------------------------------------------
    # 1. Сначала смотрим, какой speaker активен
    #    в середине слова.
    # --------------------------------------------------------

    midpoint_candidates = []

    for segment in diarization:

        if (
            segment["start"]
            <= word_mid
            <= segment["end"]
        ):
            midpoint_candidates.append(segment)

    if midpoint_candidates:

        # Если несколько speaker'ов перекрываются,
        # выбираем тот, у которого больше пересечение
        # с самим словом.

        best_segment = max(
            midpoint_candidates,
            key=lambda segment: interval_overlap(
                word_start,
                word_end,
                segment["start"],
                segment["end"],
            ),
        )

        return (
            best_segment["speaker"],
            "midpoint",
        )

    # --------------------------------------------------------
    # 2. Если середина слова не попала,
    #    считаем максимальное пересечение.
    # --------------------------------------------------------

    overlap_candidates = []

    for segment in diarization:

        overlap = interval_overlap(
            word_start,
            word_end,
            segment["start"],
            segment["end"],
        )

        if overlap > 0:
            overlap_candidates.append(
                (
                    overlap,
                    segment,
                )
            )

    if overlap_candidates:

        overlap_candidates.sort(
            key=lambda item: item[0],
            reverse=True,
        )

        best_overlap, best_segment = (
            overlap_candidates[0]
        )

        if best_overlap > 0:

            return (
                best_segment["speaker"],
                "overlap",
            )

    # --------------------------------------------------------
    # 3. Если слово вообще не попало
    #    в diarization, ищем ближайший segment.
    # --------------------------------------------------------

    nearest_segment = None
    nearest_distance = float("inf")

    for segment in diarization:

        if word_end < segment["start"]:

            distance = (
                segment["start"] - word_end
            )

        elif word_start > segment["end"]:

            distance = (
                word_start - segment["end"]
            )

        else:

            distance = 0.0

        if distance < nearest_distance:

            nearest_distance = distance
            nearest_segment = segment

    if (
        nearest_segment is not None
        and nearest_distance
        <= MAX_NEAREST_DISTANCE
    ):

        return (
            nearest_segment["speaker"],
            "nearest",
        )

    # --------------------------------------------------------
    # 4. Вообще ничего подходящего нет.
    # --------------------------------------------------------

    return None, "unknown"


# ============================================================
# FLATTEN WHISPER WORDS
# ============================================================

def flatten_words(
    transcription: dict[str, Any],
):

    words = []

    for segment in transcription.get(
        "segments",
        [],
    ):

        for word in segment.get(
            "words",
            [],
        ):

            words.append(
                {
                    "start": float(word["start"]),
                    "end": float(word["end"]),
                    "word": word["word"],
                    "probability": word.get(
                        "probability"
                    ),
                    "whisper_segment_id": segment.get(
                        "id"
                    ),
                }
            )

    words.sort(
        key=lambda x: x["start"]
    )

    return words


# ============================================================
# ALIGN
# ============================================================

def align_transcription(
    transcription: dict[str, Any],
    diarization: list[dict[str, Any]],
):

    words = flatten_words(
        transcription
    )

    aligned_words = []

    for word in words:

        speaker, method = (
            assign_word_to_speaker(
                word,
                diarization,
            )
        )

        aligned_word = {
            **word,
            "speaker": speaker,
            "assignment_method": method,
        }

        aligned_words.append(
            aligned_word
        )

    dialogue_segments = []

    current = None

    for word in aligned_words:

        speaker = word["speaker"]

        if current is None:

            current = {
                "start": word["start"],
                "end": word["end"],
                "speaker": speaker,
                "words": [word],
            }

            continue

        same_speaker = (
            current["speaker"]
            == speaker
        )

        silence = (
            word["start"]
            - current["end"]
        )

        if (
            same_speaker
            and silence
            <= MAX_SILENCE_BETWEEN_WORDS
        ):

            current["end"] = word["end"]
            current["words"].append(word)

        else:

            dialogue_segments.append(
                finalize_dialogue_segment(
                    current
                )
            )

            current = {
                "start": word["start"],
                "end": word["end"],
                "speaker": speaker,
                "words": [word],
            }

    if current is not None:

        dialogue_segments.append(
            finalize_dialogue_segment(
                current
            )
        )

    return {
        "aligned_words": aligned_words,
        "dialogue_segments": dialogue_segments,
    }


def finalize_dialogue_segment(
    segment: dict[str, Any],
):

    words = segment["words"]

    text = clean_joined_text(
        [
            word["word"]
            for word in words
        ]
    )

    return {
        "start": segment["start"],
        "end": segment["end"],
        "duration": (
            segment["end"]
            - segment["start"]
        ),
        "speaker": segment["speaker"],
        "text": text,
        "word_count": len(words),
    }


# ============================================================
# SAVE TXT
# ============================================================

def format_timestamp(
    seconds: float,
) -> str:

    minutes = int(seconds // 60)
    remaining = seconds - minutes * 60

    return (
        f"{minutes:02d}:"
        f"{remaining:05.2f}"
    )


def save_dialogue_txt(
    dialogue_segments: list[dict[str, Any]],
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

        for segment in dialogue_segments:

            start = format_timestamp(
                segment["start"]
            )

            end = format_timestamp(
                segment["end"]
            )

            speaker = (
                segment["speaker"]
                if segment["speaker"]
                else "UNKNOWN"
            )

            text = segment["text"]

            file.write(
                f"[{start} - {end}] "
                f"{speaker}:\n"
            )

            file.write(
                f"{text}\n\n"
            )

    print(
        f"[Alignment] Dialogue TXT: "
        f"{output_file}"
    )


# ============================================================
# SAVE JSON
# ============================================================

def save_dialogue_json(
    output_file: Path,
    audio_file: Path,
    transcription: dict[str, Any],
    diarization: list[dict[str, Any]],
    aligned_words: list[dict[str, Any]],
    dialogue_segments: list[dict[str, Any]],
):

    speakers = sorted(
        {
            segment["speaker"]
            for segment in diarization
        }
    )

    data = {
        "audio": audio_file.name,

        "speakers": speakers,

        "diarization": diarization,

        "aligned_words": aligned_words,

        "dialogue_segments": dialogue_segments,
    }

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
            data,
            file,
            ensure_ascii=False,
            indent=2,
        )

    print(
        f"[Alignment] Dialogue JSON: "
        f"{output_file}"
    )