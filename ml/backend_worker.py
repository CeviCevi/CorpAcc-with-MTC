from __future__ import annotations

import asyncio
import email.message
import json
import logging
import mimetypes
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

import websockets

try:
    import config as app_config
except ImportError:
    app_config = None


# ---------------------------------------------------------------------------
# Settings: values are read from config.py if they exist, otherwise defaults
# below are used. Prefer editing the BACKEND_* block in config.py.
# ---------------------------------------------------------------------------
BASE_DIR = Path(getattr(app_config, "BASE_DIR", Path(__file__).resolve().parent))
OUTPUT_DIR = Path(getattr(app_config, "OUTPUT_DIR", BASE_DIR / "output"))
TRANSCRIPTION_DIR = Path(
    getattr(app_config, "TRANSCRIPTION_DIR", OUTPUT_DIR / "transcription")
)
QWEN_OUTPUT_DIR = Path(getattr(app_config, "QWEN_OUTPUT_DIR", OUTPUT_DIR / "qwen"))

BACKEND_BASE_URL = str(
    getattr(
        app_config,
        "BACKEND_BASE_URL",
        "https://64wh7x1w-8080.euw.devtunnels.ms",
    )
).rstrip("/")
BACKEND_WEBSOCKET_URL = str(
    getattr(
        app_config,
        "BACKEND_WEBSOCKET_URL",
        "wss://64wh7x1w-8080.euw.devtunnels.ms/ws/audio",
    )
)
BACKEND_AUDIO_GET_PATH = str(
    getattr(app_config, "BACKEND_AUDIO_GET_PATH", "/api/audios/get/{id}")
)
BACKEND_TRANSCRIPTION_SAVE_PATH = str(
    getattr(
        app_config,
        "BACKEND_TRANSCRIPTION_SAVE_PATH",
        "/api/transcriptions/save/{id}",
    )
)
BACKEND_CONTRACT_SAVE_PATH = str(
    getattr(app_config, "BACKEND_CONTRACT_SAVE_PATH", "/api/contracts/save/{id}")
)
BACKEND_JOBS_DIR = Path(
    getattr(app_config, "BACKEND_JOBS_DIR", BASE_DIR / "server_jobs")
)
BACKEND_MAIN_SCRIPT = Path(
    getattr(app_config, "BACKEND_MAIN_SCRIPT", BASE_DIR / "main.py")
)
BACKEND_MAIN_AUDIO_MODE = str(
    getattr(app_config, "BACKEND_MAIN_AUDIO_MODE", "auto")
).lower()
BACKEND_HTTP_TIMEOUT_SECONDS = int(
    getattr(app_config, "BACKEND_HTTP_TIMEOUT_SECONDS", 300)
)
BACKEND_QUEUE_MAX_SIZE = int(getattr(app_config, "BACKEND_QUEUE_MAX_SIZE", 100))
BACKEND_WS_RECONNECT_SECONDS = float(
    getattr(app_config, "BACKEND_WS_RECONNECT_SECONDS", 5)
)
BACKEND_WS_PING_INTERVAL_SECONDS = float(
    getattr(app_config, "BACKEND_WS_PING_INTERVAL_SECONDS", 20)
)

# Keep this at one. The current ML pipeline writes shared files under output/;
# parallel workers could read or overwrite each other's results.
WORKER_COUNT = 1

LOG_LEVEL = logging.INFO
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("backend_worker")


class BackendRequestError(RuntimeError):
    pass


def _safe_directory_name(value: str) -> str:
    """Return a filesystem-safe folder name while retaining ordinary IDs."""
    safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("._")
    return safe or "unknown_id"


def _id_url_value(task_id: str) -> str:
    # Treat an ID as one path segment; do not allow slashes to alter the URL.
    return quote(task_id, safe="")


def _url(path_template: str, task_id: str) -> str:
    return BACKEND_BASE_URL + path_template.format(id=_id_url_value(task_id))


def _http_error_text(exc: HTTPError) -> str:
    try:
        body = exc.read().decode("utf-8", errors="replace")
    except Exception:
        body = ""
    return f"HTTP {exc.code} {exc.reason}. Ответ сервера: {body[:1000]}"


def _get_audio(task_id: str, destination_dir: Path) -> Path:
    url = _url(BACKEND_AUDIO_GET_PATH, task_id)
    request = Request(
        url,
        method="GET",
        headers={"Accept": "audio/*, application/octet-stream, */*"},
    )
    logger.info("Скачиваю аудио для ID=%s: %s", task_id, url)

    try:
        with urlopen(request, timeout=BACKEND_HTTP_TIMEOUT_SECONDS) as response:
            data = response.read()
            content_type = response.headers.get("Content-Type", "").split(";", 1)[0].strip()
            content_disposition = response.headers.get("Content-Disposition", "")
    except HTTPError as exc:
        raise BackendRequestError(f"Не удалось получить аудио: {_http_error_text(exc)}") from exc
    except (URLError, TimeoutError) as exc:
        raise BackendRequestError(f"Ошибка соединения при скачивании аудио: {exc}") from exc

    if not data:
        raise BackendRequestError(f"Бэкенд вернул пустой аудиофайл для ID={task_id}.")

    # Use the server-supplied file name if available, but only retain its extension.
    extension = ""
    if content_disposition:
        try:
            message = email.message.Message()
            message["content-disposition"] = content_disposition
            received_name = message.get_filename()
            if received_name:
                extension = Path(received_name).suffix.lower()
        except Exception:
            extension = ""

    allowed_extensions = {".mp3", ".wav", ".m4a", ".flac", ".ogg", ".opus", ".aac", ".wma", ".mp4"}
    if extension not in allowed_extensions:
        guessed = mimetypes.guess_extension(content_type) if content_type else None
        extension = guessed if guessed in allowed_extensions else ".mp3"

    # Do not silently save an HTML/JSON error page as an MP3.
    if content_type in {"application/json", "text/html", "application/problem+json"}:
        preview = data[:400].decode("utf-8", errors="replace")
        raise BackendRequestError(
            "GET /api/audios/get/{id} вернул не бинарное аудио, а "
            f"{content_type}. Начало ответа: {preview}"
        )

    destination_dir.mkdir(parents=True, exist_ok=True)
    audio_path = destination_dir / f"audio{extension}"
    audio_path.write_bytes(data)
    logger.info("Аудио сохранено: %s (%s байт)", audio_path, len(data))
    return audio_path


def _resolve_main_audio_mode() -> str:
    """Resolve whether main.py expects --audio FILE or a positional FILE."""
    mode = BACKEND_MAIN_AUDIO_MODE
    if mode in {"option", "flag", "--audio"}:
        return "option"
    if mode in {"positional", "argument"}:
        return "positional"
    if mode != "auto":
        raise ValueError(
            "BACKEND_MAIN_AUDIO_MODE должен быть 'auto', 'option' или 'positional'."
        )

    if not BACKEND_MAIN_SCRIPT.exists():
        raise FileNotFoundError(f"Не найден файл конвейера: {BACKEND_MAIN_SCRIPT}")
    source = BACKEND_MAIN_SCRIPT.read_text(encoding="utf-8", errors="replace")
    if re.search(r"add_argument\s*\(\s*['\"]--audio(?:['\" ,])", source):
        return "option"
    if re.search(r"add_argument\s*\(\s*['\"]audio['\"]", source):
        return "positional"

    # Some projects define parser.add_argument('--audio', ...) on multiple lines.
    if "--audio" in source and "arguments.audio" in source:
        return "option"
    if "arguments.audio" in source:
        return "positional"
    raise RuntimeError(
        "Не удалось определить способ передачи аудио в main.py. "
        "Укажи BACKEND_MAIN_AUDIO_MODE='option' или 'positional' в config.py."
    )


def _build_pipeline_command(audio_path: Path) -> list[str]:
    mode = _resolve_main_audio_mode()
    command = [sys.executable, str(BACKEND_MAIN_SCRIPT)]
    if mode == "option":
        command.extend(["--audio", str(audio_path)])
    else:
        command.append(str(audio_path))
    return command


def _candidate_result_paths(audio_stem: str) -> tuple[list[Path], list[Path]]:
    """Preferred outputs first: Qwen's final text/context, then aligned dialogue."""
    txt_candidates = [
        QWEN_OUTPUT_DIR / f"{audio_stem}_dialog.txt",
        QWEN_OUTPUT_DIR / "dialogue.txt",
        OUTPUT_DIR / "qwen_result.txt",
        OUTPUT_DIR / "dialogue.txt",
        TRANSCRIPTION_DIR / f"{audio_stem}.txt",
        OUTPUT_DIR / f"{audio_stem}.txt",
    ]
    json_candidates = [
        QWEN_OUTPUT_DIR / f"{audio_stem}_summary.json",
        QWEN_OUTPUT_DIR / "context.json",
        QWEN_OUTPUT_DIR / f"{audio_stem}_context.json",
        OUTPUT_DIR / "contracts.json",
        OUTPUT_DIR / "dialogue.json",
        TRANSCRIPTION_DIR / f"{audio_stem}.json",
        OUTPUT_DIR / f"{audio_stem}.json",
    ]
    # Keep only first occurrence of each path.
    return list(dict.fromkeys(txt_candidates)), list(dict.fromkeys(json_candidates))


def _file_signature(path: Path) -> tuple[int, int] | None:
    try:
        stat = path.stat()
        return stat.st_mtime_ns, stat.st_size
    except FileNotFoundError:
        return None


def _signature_snapshot(paths: list[Path]) -> dict[Path, tuple[int, int] | None]:
    return {path: _file_signature(path) for path in paths}


def _find_fresh_result(
    candidates: list[Path],
    previous_signatures: dict[Path, tuple[int, int] | None],
    kind: str,
) -> Path:
    for path in candidates:
        current_signature = _file_signature(path)
        if current_signature is not None and current_signature != previous_signatures.get(path):
            if current_signature[1] > 0:
                return path
    existing = [str(path) for path in candidates if path.exists()]
    raise FileNotFoundError(
        f"Не найден новый файл результата {kind}. Проверены: {candidates}. "
        f"Уже существующие, но не обновлённые файлы: {existing}"
    )


def _run_ml_pipeline(audio_path: Path) -> None:
    command = _build_pipeline_command(audio_path)
    logger.info("Запускаю ML-конвейер: %s", subprocess.list2cmdline(command))
    # Inherit console output so progress from Whisper/NeMo/Qwen is visible live.
    completed = subprocess.run(command, cwd=str(BASE_DIR), check=False)
    if completed.returncode != 0:
        raise RuntimeError(f"ML-конвейер завершился с кодом {completed.returncode}.")


def _post_bytes(url: str, payload: bytes, content_type: str) -> str:
    request = Request(
        url,
        data=payload,
        method="POST",
        headers={
            "Content-Type": content_type,
            "Accept": "application/json, text/plain, */*",
        },
    )
    try:
        with urlopen(request, timeout=BACKEND_HTTP_TIMEOUT_SECONDS) as response:
            response_body = response.read().decode("utf-8", errors="replace")
            logger.info("POST %s -> HTTP %s", url, response.status)
            return response_body
    except HTTPError as exc:
        raise BackendRequestError(f"Не удалось отправить результат: {_http_error_text(exc)}") from exc
    except (URLError, TimeoutError) as exc:
        raise BackendRequestError(f"Ошибка соединения при отправке результата: {exc}") from exc


def process_one_id(task_id: str) -> None:
    """Download audio, run ML, and send TXT + JSON for one ID."""
    safe_id = _safe_directory_name(task_id)
    job_dir = BACKEND_JOBS_DIR / safe_id
    input_dir = job_dir / "input"
    result_dir = job_dir / "sent_results"
    result_dir.mkdir(parents=True, exist_ok=True)

    txt_candidates, json_candidates = _candidate_result_paths(audio_stem=f"audio")
    # The extension is determined from response headers, so the real stem is audio.
    all_candidates = list(dict.fromkeys(txt_candidates + json_candidates))
    previous_signatures = _signature_snapshot(all_candidates)

    audio_path = _get_audio(task_id, input_dir)
    # Main derives output names from audio_path.stem; use the stable stem "audio".
    txt_candidates, json_candidates = _candidate_result_paths(audio_stem=audio_path.stem)
    for path in txt_candidates + json_candidates:
        if path not in previous_signatures:
            previous_signatures[path] = _file_signature(path)

    logger.info("Обрабатываю ID=%s", task_id)
    _run_ml_pipeline(audio_path)

    txt_path = _find_fresh_result(txt_candidates, previous_signatures, "TXT")
    json_path = _find_fresh_result(json_candidates, previous_signatures, "JSON")

    txt_content = txt_path.read_text(encoding="utf-8-sig", errors="replace")
    if not txt_content.strip():
        raise RuntimeError(f"TXT-результат пустой: {txt_path}")
    try:
        json_content: Any = json.loads(json_path.read_text(encoding="utf-8-sig"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"JSON-результат некорректен: {json_path}: {exc}") from exc

    # Preserve a local copy of exactly what will be sent to the backend.
    sent_txt_path = result_dir / "transcription.txt"
    sent_json_path = result_dir / "contracts.json"
    sent_txt_path.write_text(txt_content, encoding="utf-8")
    sent_json_path.write_text(
        json.dumps(json_content, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    txt_url = _url(BACKEND_TRANSCRIPTION_SAVE_PATH, task_id)
    json_url = _url(BACKEND_CONTRACT_SAVE_PATH, task_id)

    # Requirement: TXT as a raw string (text/plain), not a JSON wrapper.
    _post_bytes(txt_url, txt_content.encode("utf-8"), "text/plain; charset=utf-8")

    # Requirement: JSON as actual JSON document.
    json_payload = json.dumps(json_content, ensure_ascii=False).encode("utf-8")
    _post_bytes(json_url, json_payload, "application/json; charset=utf-8")

    logger.info(
        "Задача ID=%s завершена. TXT: %s; JSON: %s",
        task_id,
        sent_txt_path,
        sent_json_path,
    )


def extract_id(message: str | bytes) -> str | None:
    """Accept a raw numeric/string ID or common JSON object shapes."""
    if isinstance(message, bytes):
        message = message.decode("utf-8", errors="replace")
    raw = message.strip()
    if not raw:
        return None

    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        # A plain frame such as: 123
        return raw if re.fullmatch(r"[A-Za-z0-9_.:-]+", raw) else None

    if isinstance(parsed, (int, float)) and not isinstance(parsed, bool):
        return str(int(parsed)) if float(parsed).is_integer() else str(parsed)
    if isinstance(parsed, str):
        value = parsed.strip()
        return value or None
    if isinstance(parsed, dict):
        for key in ("id", "audioId", "audio_id", "userId", "user_id"):
            value = parsed.get(key)
            if isinstance(value, (str, int)) and not isinstance(value, bool):
                value = str(value).strip()
                if value:
                    return value
        for key in ("data", "payload", "message"):
            if key in parsed:
                nested = parsed[key]
                if isinstance(nested, dict):
                    nested_raw = json.dumps(nested, ensure_ascii=False)
                elif isinstance(nested, (str, int)):
                    nested_raw = str(nested)
                else:
                    continue
                result = extract_id(nested_raw)
                if result:
                    return result
    return None


async def queue_worker(
    queue: asyncio.Queue[str],
    active_ids: set[str],
) -> None:
    while True:
        task_id = await queue.get()
        try:
            await asyncio.to_thread(process_one_id, task_id)
        except Exception:
            logger.exception("Обработка ID=%s завершилась ошибкой; очередь продолжит работу.", task_id)
        finally:
            active_ids.discard(task_id)
            queue.task_done()


async def websocket_listener(
    queue: asyncio.Queue[str],
    active_ids: set[str],
) -> None:
    while True:
        try:
            logger.info("Подключаюсь к WebSocket: %s", BACKEND_WEBSOCKET_URL)
            async with websockets.connect(
                BACKEND_WEBSOCKET_URL,
                ping_interval=BACKEND_WS_PING_INTERVAL_SECONDS,
                ping_timeout=BACKEND_WS_PING_INTERVAL_SECONDS,
                max_size=1024 * 1024,
                open_timeout=20,
                close_timeout=10,
            ) as websocket:
                logger.info("WebSocket подключён. Ожидаю ID...")
                async for message in websocket:
                    task_id = extract_id(message)
                    if task_id is None:
                        logger.warning("Не распознал ID из WebSocket-сообщения: %r", message)
                        continue
                    if task_id in active_ids:
                        logger.info("ID=%s уже находится в очереди или обрабатывается; дубль пропущен.", task_id)
                        continue
                    active_ids.add(task_id)
                    logger.info("Получен ID=%s. В очереди до добавления: %s", task_id, queue.qsize())
                    try:
                        await queue.put(task_id)
                    except BaseException:
                        active_ids.discard(task_id)
                        raise
        except asyncio.CancelledError:
            raise
        except Exception as exc:
            logger.error("WebSocket отключён/недоступен: %s", exc)
            logger.info("Повторное подключение через %.1f секунд.", BACKEND_WS_RECONNECT_SECONDS)
            await asyncio.sleep(BACKEND_WS_RECONNECT_SECONDS)


async def main_async() -> None:
    if not BACKEND_MAIN_SCRIPT.exists():
        raise FileNotFoundError(f"Не найден main.py: {BACKEND_MAIN_SCRIPT}")
    if BACKEND_QUEUE_MAX_SIZE < 1:
        raise ValueError("BACKEND_QUEUE_MAX_SIZE должен быть больше нуля.")

    BACKEND_JOBS_DIR.mkdir(parents=True, exist_ok=True)
    queue: asyncio.Queue[str] = asyncio.Queue(maxsize=BACKEND_QUEUE_MAX_SIZE)
    active_ids: set[str] = set()

    worker_tasks = [
        asyncio.create_task(queue_worker(queue, active_ids), name=f"queue-worker-{i + 1}")
        for i in range(WORKER_COUNT)
    ]
    listener_task = asyncio.create_task(
        websocket_listener(queue, active_ids), name="websocket-listener"
    )

    try:
        await asyncio.gather(listener_task, *worker_tasks)
    finally:
        listener_task.cancel()
        for task in worker_tasks:
            task.cancel()
        await asyncio.gather(listener_task, *worker_tasks, return_exceptions=True)


def main() -> None:
    logger.info("Старт фонового обработчика аудио")
    logger.info("HTTP base URL: %s", BACKEND_BASE_URL)
    logger.info("WebSocket URL: %s", BACKEND_WEBSOCKET_URL)
    logger.info("Очередь: максимум %s задач; одновременных ML-обработчиков: %s", BACKEND_QUEUE_MAX_SIZE, WORKER_COUNT)
    try:
        asyncio.run(main_async())
    except KeyboardInterrupt:
        logger.info("Остановка по Ctrl+C")


if __name__ == "__main__":
    main()
