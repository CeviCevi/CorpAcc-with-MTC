from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

from config import OUTPUT_DIR, QWEN_CHUNK_CHARS, QWEN_MAX_NEW_TOKENS
from qwen_llm import QwenTransformers

QWEN_OUTPUT_DIR = OUTPUT_DIR / "qwen"

# Closed label vocabulary. Labels are written by Python so the model cannot rename them.
TAG = {
    "name": "[name]",
    "user": "[user]",
    "role": "[role]",
    "company_name": "[company_name]",
    "description": "[description]",
    "speaker_id": "[speaker_id]",
    "agreement": "[agreement]",
    "subject": "[subject]",
    "from_company": "[from_company]",
    "to_company": "[to_company]",
    "from_gives": "[from_gives]",
    "to_gives": "[to_gives]",
    "conditions": "[conditions]",
    "deadline": "[deadline]",
    "status": "[status]",
    "evidence_segment_ids": "[evidence_segment_ids]",
    "date": "[date]",
    "representative": "[representative]",
    "open_question": "[open_question]",
    "summary": "[summary]",
}


def obj(properties: dict[str, Any]) -> dict[str, Any]:
    return {
        "type": "object",
        "additionalProperties": False,
        "properties": properties,
        "required": list(properties.keys()),
    }


def arr(item_schema: dict[str, Any]) -> dict[str, Any]:
    return {"type": "array", "items": item_schema}


STR = {"type": "string"}
INT = {"type": "integer"}
REPRESENTATIVE_SCHEMA = obj({"speaker": STR, "name": STR, "role": STR})
AGREEMENT_SCHEMA = obj({
    "from_company": STR,
    "to_company": STR,
    "subject": STR,
    "from_gives": STR,
    "to_gives": STR,
    "conditions": arr(STR),
    "deadline": STR,
    "status": STR,
    "evidence_segment_ids": arr(INT),
})
CHUNK_SCHEMA = obj({
    # Place the overview first so it is more likely to survive if output token limits are hit.
    "topic_summary": STR,
    "speaker_candidates": arr(obj({
        "speaker": STR,
        "name": STR,
        "role": STR,
        "company": STR,
        "confidence": {"type": "number"},
        "evidence_segment_ids": arr(INT),
    })),
    "companies": arr(obj({
        "name": STR,
        "representatives": arr(REPRESENTATIVE_SCHEMA),
        "evidence_segment_ids": arr(INT),
    })),
    "agreements": arr(AGREEMENT_SCHEMA),
})

SYSTEM_PROMPT = """
Ты анализируешь стенограмму аудио. Это может быть деловой разговор, собеседование,
интервью, консультация, бытовой разговор или другой тип диалога.
Не переписывай исходные реплики и не исправляй их. Не выдумывай факты.

Верни следующие поля:
1) topic_summary — краткое описание того, о чём говорится в данном фрагменте,
   обычно 1–3 предложения. Обязательно заполни это поле, даже если нет компаний,
   коммерческих предложений или договорённостей. Назови тему разговора и основные
   обсуждавшиеся вопросы, опираясь только на стенограмму. Не пиши вместо этого
   «договорённостей нет» — это не описание темы.
2) speaker_candidates — подтверждённое имя, роль/должность и компания каждого
   существующего SPEAKER_X. Если человек явно представляется фразой вроде
   «Меня зовут ...», свяжи имя именно с произнесшим эту реплику говорящим.
3) companies — компании и подтверждённые представители, только если они названы.
4) agreements — только реально обсуждавшиеся коммерческие предложения, сделки
   или договорённости. Не превращай обычные ответы, собеседование или обсуждение
   общих тем в коммерческую сделку. Если таких договорённостей нет, верни [].

Имя, упомянутое не в самопредставлении, само по себе не подтверждает личность говорящего.
Не придумывай людей, компании, должности, даты, условия, суммы и сроки.
Для каждого объекта указывай evidence_segment_ids — номера существующих реплик,
которые действительно подтверждают этот объект. Не создавай новых говорящих.
Допустимые статусы соглашений: agreed, proposed, discussed, rejected, unknown.

Верни только JSON, соответствующий схеме. Никакого текста вне JSON.
""".strip()

STATUS_RU = {
    "agreed": "согласовано",
    "proposed": "предложено",
    "discussed": "обсуждается",
    "rejected": "отклонено",
    "unknown": "не установлен",
}
VALID_STATUSES = set(STATUS_RU)


def norm(value: Any) -> str:
    text = str(value or "").lower().replace("ё", "е").replace("—", "-")
    return re.sub(r"\s+", " ", text).strip()


def as_str(value: Any) -> str:
    return value.strip() if isinstance(value, str) else ""


def empty_to_none(value: Any) -> Any:
    return value if not isinstance(value, str) or value.strip() else None


def tagged(tag_key: str, value: Any) -> dict[str, Any]:
    return {"tag": TAG[tag_key], "value": value}


def load_dialogue(path: Path) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    with path.open("r", encoding="utf-8") as file:
        data = json.load(file)
    records = []
    for index, segment in enumerate(data.get("dialogue_segments", []), start=1):
        records.append({
            "id": index,
            "start": float(segment["start"]),
            "end": float(segment["end"]),
            "speaker": as_str(segment.get("speaker")) or "UNKNOWN",
            "text": as_str(segment.get("text")),
        })
    return data, records


def format_time(seconds: float) -> str:
    minutes = int(seconds // 60)
    return f"{minutes:02d}:{seconds - minutes * 60:05.2f}"


def build_chunks(records: list[dict[str, Any]]) -> list[list[dict[str, Any]]]:
    chunks: list[list[dict[str, Any]]] = []
    current: list[dict[str, Any]] = []
    current_chars = 0
    for record in records:
        line_length = len(
            f"[{record['id']}] {format_time(record['start'])} - "
            f"{format_time(record['end'])} {record['speaker']}: {record['text']}\n"
        )
        if current and current_chars + line_length > QWEN_CHUNK_CHARS:
            chunks.append(current)
            current = []
            current_chars = 0
        current.append(record)
        current_chars += line_length
    if current:
        chunks.append(current)
    return chunks


def serialize_chunk(records: list[dict[str, Any]]) -> str:
    return "\n".join(
        f"[{r['id']}] {format_time(r['start'])} - {format_time(r['end'])} "
        f"{r['speaker']}: {r['text']}"
        for r in records
    )


def validate_ids(values: Any, valid_ids: set[int]) -> list[int]:
    if not isinstance(values, list):
        return []
    result = set()
    for value in values:
        try:
            number = int(value)
        except (TypeError, ValueError):
            continue
        if number in valid_ids:
            result.add(number)
    return sorted(result)


def extract_chunk(qwen: QwenTransformers, records: list[dict[str, Any]]) -> dict[str, Any]:
    prompt = (
        "Проанализируй только этот фрагмент. Числа в квадратных скобках — ID реплик. "
        "Обязательно опиши тему фрагмента в topic_summary, даже если договорённостей нет.\n\n"
        + serialize_chunk(records)
    )
    raw = qwen.chat_json(
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt},
        ],
        schema=CHUNK_SCHEMA,
        max_tokens=QWEN_MAX_NEW_TOKENS,
    )
    valid_ids = {r["id"] for r in records}
    valid_speakers = {r["speaker"] for r in records}
    result: dict[str, Any] = {
        "topic_summary": as_str(raw.get("topic_summary")),
        "speaker_candidates": [],
        "companies": [],
        "agreements": [],
    }

    for item in raw.get("speaker_candidates", []):
        if not isinstance(item, dict):
            continue
        speaker = as_str(item.get("speaker"))
        evidence = validate_ids(item.get("evidence_segment_ids"), valid_ids)
        if speaker not in valid_speakers or not evidence:
            continue
        try:
            confidence = float(item.get("confidence", 0))
        except (TypeError, ValueError):
            confidence = 0.0
        result["speaker_candidates"].append({
            "speaker": speaker,
            "name": as_str(item.get("name")),
            "role": as_str(item.get("role")),
            "company": as_str(item.get("company")),
            "confidence": max(0.0, min(1.0, confidence)),
            "evidence_segment_ids": evidence,
        })

    for item in raw.get("companies", []):
        if not isinstance(item, dict):
            continue
        name = as_str(item.get("name"))
        evidence = validate_ids(item.get("evidence_segment_ids"), valid_ids)
        if not name or not evidence:
            continue
        representatives = []
        for rep in item.get("representatives", []):
            if not isinstance(rep, dict):
                continue
            speaker = as_str(rep.get("speaker"))
            if speaker and speaker not in valid_speakers:
                continue
            representatives.append({
                "speaker": speaker,
                "name": as_str(rep.get("name")),
                "role": as_str(rep.get("role")),
            })
        result["companies"].append({
            "name": name,
            "representatives": representatives,
            "evidence_segment_ids": evidence,
        })

    for item in raw.get("agreements", []):
        if not isinstance(item, dict):
            continue
        evidence = validate_ids(item.get("evidence_segment_ids"), valid_ids)
        if not evidence:
            continue
        status = as_str(item.get("status")).lower()
        if status not in VALID_STATUSES:
            status = "unknown"
        conditions = item.get("conditions", [])
        if not isinstance(conditions, list):
            conditions = []
        agreement = {
            "from_company": as_str(item.get("from_company")),
            "to_company": as_str(item.get("to_company")),
            "subject": as_str(item.get("subject")),
            "from_gives": as_str(item.get("from_gives")),
            "to_gives": as_str(item.get("to_gives")),
            "conditions": [str(x).strip() for x in conditions if str(x).strip()],
            "deadline": as_str(item.get("deadline")),
            "status": status,
            "evidence_segment_ids": evidence,
        }
        if any(agreement[key] for key in ("from_company", "to_company", "subject", "from_gives", "to_gives")):
            result["agreements"].append(agreement)
    return result


def merge_speakers(results: list[dict[str, Any]]) -> dict[str, Any]:
    by_speaker: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for result in results:
        for item in result["speaker_candidates"]:
            by_speaker[item["speaker"]].append(item)

    merged: dict[str, Any] = {}
    for speaker, candidates in by_speaker.items():
        candidates.sort(
            key=lambda item: (item["confidence"], len(item["evidence_segment_ids"])),
            reverse=True,
        )
        best = candidates[0]
        if best["confidence"] < 0.70:
            merged[speaker] = {
                "name": None, "role": None, "company": None,
                "confidence": best["confidence"],
                "evidence_segment_ids": best["evidence_segment_ids"],
            }
        else:
            merged[speaker] = {
                "name": empty_to_none(best["name"]),
                "role": empty_to_none(best["role"]),
                "company": empty_to_none(best["company"]),
                "confidence": best["confidence"],
                "evidence_segment_ids": best["evidence_segment_ids"],
            }
    return merged


def apply_explicit_introductions(
    records: list[dict[str, Any]], speaker_mapping: dict[str, Any]
) -> dict[str, Any]:
    """Use explicit self-introductions as high-confidence evidence for speaker names."""
    name_pattern = re.compile(
        r"(?i:\bменя зовут|\bmy name is|\bich hei(?:ß|ss)e)\s+"
        r"([A-ZА-ЯЁ][A-Za-zА-Яа-яЁё'’-]*(?:\s+[A-ZА-ЯЁ][A-Za-zА-Яа-яЁё'’-]*){1,2})"
    )
    for record in records:
        match = name_pattern.search(record["text"])
        speaker = record["speaker"]
        if not match or speaker == "UNKNOWN":
            continue
        name = match.group(1).strip().rstrip(".,!?;:")
        info = speaker_mapping.setdefault(speaker, {
            "name": None, "role": None, "company": None,
            "confidence": 1.0, "evidence_segment_ids": [],
        })
        # A first-person self-introduction links the name to this exact speaker.
        info["name"] = name
        info["confidence"] = max(float(info.get("confidence") or 0.0), 1.0)
        evidence = list(info.get("evidence_segment_ids") or [])
        if record["id"] not in evidence:
            evidence.append(record["id"])
        info["evidence_segment_ids"] = sorted(evidence)
    return speaker_mapping


def merge_companies(results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    companies: dict[str, dict[str, Any]] = {}
    for result in results:
        for company in result["companies"]:
            key = norm(company["name"])
            if not key:
                continue
            target = companies.setdefault(key, {
                "name": company["name"],
                "representatives": [],
                "evidence_segment_ids": [],
            })
            target["evidence_segment_ids"].extend(company["evidence_segment_ids"])
            for rep in company["representatives"]:
                if rep not in target["representatives"]:
                    target["representatives"].append(rep)
    for company in companies.values():
        company["evidence_segment_ids"] = sorted(set(company["evidence_segment_ids"]))
    return list(companies.values())


def merge_agreements(results: list[dict[str, Any]]) -> list[dict[str, Any]]:
    merged: dict[tuple[str, ...], dict[str, Any]] = {}
    fields = ("from_company", "to_company", "subject", "from_gives", "to_gives")
    for result in results:
        for agreement in result["agreements"]:
            key = tuple(norm(agreement[field]) for field in fields)
            if key not in merged:
                merged[key] = dict(agreement)
                continue
            target = merged[key]
            target["evidence_segment_ids"] = sorted(set(
                target["evidence_segment_ids"] + agreement["evidence_segment_ids"]
            ))
            target["conditions"] = list(dict.fromkeys(
                target["conditions"] + agreement["conditions"]
            ))
            if target["status"] in {"unknown", "discussed"} and agreement["status"] in {
                "agreed", "proposed", "rejected"
            }:
                target["status"] = agreement["status"]
            if not target["deadline"]:
                target["deadline"] = agreement["deadline"]
    return list(merged.values())


def enrich_companies_from_speakers(
    companies: list[dict[str, Any]], speaker_mapping: dict[str, Any]
) -> list[dict[str, Any]]:
    by_name = {norm(item["name"]): item for item in companies}
    for speaker, info in speaker_mapping.items():
        company_name = as_str(info.get("company"))
        if not company_name:
            continue
        target = by_name.get(norm(company_name))
        if target is None:
            continue
        rep = {
            "speaker": speaker,
            "name": as_str(info.get("name")),
            "role": as_str(info.get("role")),
        }
        if any(rep.values()) and rep not in target["representatives"]:
            target["representatives"].append(rep)
    return companies


def get_date(dialogue_data: dict[str, Any]) -> str:
    audio = dialogue_data.get("audio")
    return as_str(audio.get("date")) if isinstance(audio, dict) else ""


def combine_topic_summaries(results: list[dict[str, Any]], records: list[dict[str, Any]]) -> str:
    summaries = []
    seen = set()
    for result in results:
        summary = as_str(result.get("topic_summary"))
        key = norm(summary)
        if summary and key not in seen:
            seen.add(key)
            summaries.append(summary)
    if len(summaries) == 1:
        return summaries[0]
    if summaries:
        return "В ходе разговора обсуждались следующие темы: " + " ".join(summaries)

    # Deterministic fallback if the model omitted the summary field.
    transcript_excerpt = " ".join(r["text"] for r in records if r["text"]).strip()
    if len(transcript_excerpt) > 650:
        transcript_excerpt = transcript_excerpt[:647].rsplit(" ", 1)[0] + "…"
    if transcript_excerpt:
        return "Краткое автоматическое описание не сформировано. По расшифровке разговор касается следующего: " + transcript_excerpt
    return "Тему разговора не удалось определить по имеющейся расшифровке."


def build_context(
    dialogue_data: dict[str, Any],
    records: list[dict[str, Any]],
    speaker_mapping: dict[str, Any],
    report: dict[str, Any],
    topic_summary: str,
) -> dict[str, Any]:
    speakers = []
    seen_speakers = set()
    for record in records:
        speaker = record["speaker"]
        if speaker in seen_speakers:
            continue
        seen_speakers.add(speaker)
        info = speaker_mapping.get(speaker) or {}
        annotations = [tagged("speaker_id", speaker)]
        name = as_str(info.get("name"))
        role = as_str(info.get("role"))
        company = as_str(info.get("company"))
        if name:
            annotations.extend([tagged("name", name), tagged("user", name)])
        if role:
            annotations.append(tagged("role", role))
        if company:
            annotations.append(tagged("company_name", company))
        description = "; ".join(
            [part for part in [role, f"представитель {company}" if company else ""] if part]
        )
        if description:
            annotations.append(tagged("description", description))
        speakers.append({"speaker_id": speaker, "annotations": annotations})

    companies = []
    for company in report["companies"]:
        representatives = []
        for rep in company.get("representatives", []):
            annotations = []
            if rep.get("speaker"):
                annotations.append(tagged("speaker_id", rep["speaker"]))
            if rep.get("name"):
                annotations.extend([tagged("name", rep["name"]), tagged("user", rep["name"])])
            if rep.get("role"):
                annotations.append(tagged("role", rep["role"]))
            representatives.append({
                "tag": TAG["representative"],
                "speaker_id": rep.get("speaker", ""),
                "annotations": annotations,
            })
        company_evidence = next(
            (c.get("evidence_segment_ids", []) for c in report.get("company_evidence", [])
             if norm(c.get("name")) == norm(company.get("name"))), []
        )
        companies.append({
            "tag": TAG["company_name"],
            "value": company.get("name", ""),
            "representatives": representatives,
            "evidence_segment_ids": company_evidence,
        })

    agreements = []
    open_questions = []
    seen_questions = set()
    for agreement in report["agreements"]:
        agreements.append({
            "tag": TAG["agreement"],
            "subject": tagged("subject", agreement.get("subject", "")),
            "from_company": tagged("from_company", agreement.get("from_company", "")),
            "to_company": tagged("to_company", agreement.get("to_company", "")),
            "from_gives": tagged("from_gives", agreement.get("from_gives", "")),
            "to_gives": tagged("to_gives", agreement.get("to_gives", "")),
            "conditions": [tagged("conditions", item) for item in agreement.get("conditions", [])],
            "deadline": tagged("deadline", agreement.get("deadline", "")),
            "status": {
                "tag": TAG["status"],
                "value": agreement.get("status", "unknown"),
                "display": STATUS_RU.get(agreement.get("status"), "не установлен"),
            },
            "evidence_segment_ids": tagged("evidence_segment_ids", agreement.get("evidence_segment_ids", [])),
        })
        if agreement.get("status") in {"proposed", "discussed", "unknown"}:
            subject = agreement.get("subject") or "без названия"
            evidence = agreement.get("evidence_segment_ids", [])
            for field, message in (
                ("deadline", f"Не установлен срок по вопросу «{subject}»."),
                ("conditions", f"Не уточнены условия по вопросу «{subject}»."),
            ):
                if not agreement.get(field) and message not in seen_questions:
                    seen_questions.add(message)
                    open_questions.append({
                        "tag": TAG["open_question"],
                        "value": message,
                        "evidence_segment_ids": evidence,
                    })

    audio = dialogue_data.get("audio", "")
    return {
        "audio": audio,
        "date": tagged("date", report.get("date", "")),
        "speakers": speakers,
        "companies": companies,
        "agreements": agreements,
        "open_questions": open_questions,
        "summary": tagged("summary", topic_summary),
        "tag_vocabulary": TAG,
    }


def speaker_label(speaker: str, speaker_mapping: dict[str, Any]) -> str:
    info = speaker_mapping.get(speaker) or {}
    name = as_str(info.get("name"))
    role = as_str(info.get("role"))
    company = as_str(info.get("company"))
    if not name:
        return speaker
    details = []
    if role:
        details.append(role)
    if company:
        details.append(f"представитель {company}")
    return f"{name} ({', '.join(details)})" if details else name


def save_dialogue_txt(
    records: list[dict[str, Any]], speaker_mapping: dict[str, Any], output_file: Path
) -> None:
    """Save a readable text transcript; every segment has its own time and speaker label."""
    with output_file.open("w", encoding="utf-8") as file:
        for record in records:
            label = speaker_label(record["speaker"], speaker_mapping)
            file.write(
                f"[{format_time(record['start'])} - {format_time(record['end'])}] "
                f"{label}: {record['text']}\n"
            )


def save_json(path: Path, data: Any) -> None:
    with path.open("w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
        file.write("\n")


def remove_old_qwen_artifacts() -> None:
    """Keep only dialogue.txt and context.json among Qwen's generated artifacts."""
    keep = {"dialogue.txt", "context.json"}
    for path in QWEN_OUTPUT_DIR.iterdir():
        if path.is_file() and path.name not in keep and path.suffix.lower() in {".json", ".log", ".txt"}:
            try:
                path.unlink()
            except OSError as exc:
                print(f"[Qwen] Не удалось удалить старый файл {path.name}: {exc}", flush=True)


def run_qwen_pipeline(dialogue_json: Path) -> dict[str, Any]:
    QWEN_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    dialogue_data, records = load_dialogue(dialogue_json)
    if not records:
        raise RuntimeError("dialogue.json не содержит dialogue_segments.")

    chunks = build_chunks(records)
    print("\n" + "=" * 64 + "\n[Qwen] АНАЛИЗ\n" + "=" * 64, flush=True)
    print(f"[Qwen] Реплик: {len(records)}; частей: {len(chunks)}", flush=True)

    qwen = QwenTransformers()
    try:
        chunk_results = []
        for index, chunk in enumerate(chunks, start=1):
            print(f"\n[Qwen] Часть {index}/{len(chunks)} ({len(chunk)} реплик)", flush=True)
            result = extract_chunk(qwen, chunk)
            chunk_results.append(result)
            print(
                f"[Qwen] Найдено: говорящих-кандидатов {len(result['speaker_candidates'])}, "
                f"компаний {len(result['companies'])}, сделок {len(result['agreements'])}; "
                f"тема: {'есть' if result['topic_summary'] else 'не сформирована'}",
                flush=True,
            )

        speaker_mapping = merge_speakers(chunk_results)
        speaker_mapping = apply_explicit_introductions(records, speaker_mapping)
        companies = merge_companies(chunk_results)
        companies = enrich_companies_from_speakers(companies, speaker_mapping)
        agreements = merge_agreements(chunk_results)
        report = {
            "date": get_date(dialogue_data),
            "companies": [
                {
                    "name": company["name"],
                    "representatives": company["representatives"],
                }
                for company in companies
            ],
            "company_evidence": companies,
            "agreements": agreements,
        }
        topic_summary = combine_topic_summaries(chunk_results, records)
        context = build_context(dialogue_data, records, speaker_mapping, report, topic_summary)

        dialogue_out = QWEN_OUTPUT_DIR / "dialogue.txt"
        context_out = QWEN_OUTPUT_DIR / "context.json"
        save_dialogue_txt(records, speaker_mapping, dialogue_out)
        save_json(context_out, context)
        remove_old_qwen_artifacts()

        print("\n[Qwen] ГОТОВО", flush=True)
        print(f"[Qwen] Диалог TXT: {dialogue_out}", flush=True)
        print(f"[Qwen] Контекст JSON: {context_out}", flush=True)
        if not agreements:
            print("[Qwen] Коммерческих договорённостей нет; в context.json сохранено описание темы разговора.", flush=True)
        return report
    finally:
        qwen.close()
