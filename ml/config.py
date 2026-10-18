from __future__ import annotations

from pathlib import Path

# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "output"
DIARIZATION_DIR = OUTPUT_DIR / "diarization"
TRANSCRIPTION_DIR = OUTPUT_DIR / "transcription"
AUDIO_FILE = BASE_DIR / "input" / "test_10.mp3"

# ============================================================
# AUDIO
# ============================================================

SAMPLE_RATE = 16000
CHANNELS = 1

# ============================================================
# WHISPER
# ============================================================

WHISPER_MODEL = "large-v3-turbo"
WHISPER_DEVICE = "cuda"
WHISPER_COMPUTE_TYPE = "int8_float16"

# None = automatic multilingual detection. This keeps RU/DE/EN possible.
WHISPER_LANGUAGE = None
WHISPER_MULTILINGUAL = True
WHISPER_TASK = "transcribe"
WHISPER_BEAM_SIZE = 5
WHISPER_VAD_FILTER = False
WHISPER_CONDITION_ON_PREVIOUS_TEXT = False
WHISPER_WORD_TIMESTAMPS = True
WHISPER_LANGUAGE_DETECTION_THRESHOLD = 0.5
WHISPER_LANGUAGE_DETECTION_SEGMENTS = 1

# ============================================================
# NEMO SPEECH.CPP / DIARIZATION
# ============================================================

NEMO_SPEECH = (
    Path.home()
    / "AppData" / "Local" / "Programs" / "NeMoSpeech"
    / "bin" / "nemo-speech.exe"
)
DIARIZATION_MODEL = "nemotron-3-diarization"
DIARIZATION_DEVICE = "cuda"
DIARIZATION_PRESET = "v3-offline"
MAX_SPEAKERS = 8  # Informational; does not set the CLI model's speaker count.

DIARIZATION_ONSET = 0.30
DIARIZATION_OFFSET = 0.30
PAD_ONSET = 0.00
PAD_OFFSET = 0.00
MIN_DURATION_ON = None
MIN_DURATION_OFF = 0.20

# ============================================================
# ALIGNMENT
# ============================================================

MAX_NEAREST_DISTANCE = 0.35
MAX_SILENCE_BETWEEN_WORDS = 1.5

# ============================================================
# PIPELINE
# ============================================================

RUN_SPEECH = True
RUN_DIARIZATION = True
RUN_ALIGNMENT = True
RUN_QWEN = True

# ============================================================
# QWEN / TRANSFORMERS
# ============================================================

# Use the project-local Qwen2.5-3B model; optional alternative local Transformers model is the fallback.
QWEN_MODEL_CANDIDATES = (
    BASE_DIR / "models" / "qwen" / "Qwen2.5-3B-Instruct",
    BASE_DIR / "models" / "qwen_transformers",
)
QWEN_CHUNK_CHARS = 12000
QWEN_MAX_NEW_TOKENS = 500
QWEN_4BIT = True
QWEN_COMPUTE_DTYPE = "float16"

# ============================================================
# BACKEND INTEGRATION
# ============================================================

BACKEND_BASE_URL = "https://64wh7x1w-8080.euw.devtunnels.ms"
BACKEND_WEBSOCKET_URL = "wss://64wh7x1w-8080.euw.devtunnels.ms/ws/audio"

# HTTP API routes
BACKEND_AUDIO_GET_PATH = "/api/audios/get/{id}"
BACKEND_TRANSCRIPTION_SAVE_PATH = "/api/transcriptions/save/{id}"
BACKEND_CONTRACT_SAVE_PATH = "/api/contracts/save/{id}"

# Working files and the existing ML entry point
BACKEND_JOBS_DIR = BASE_DIR / "server_jobs"
BACKEND_MAIN_SCRIPT = BASE_DIR / "main.py"

# How the existing main.py accepts the audio path:
# "auto" detects argparse --audio or positional argument from main.py source.
# If detection fails, set "option" for: python main.py --audio <file>
# or "positional" for: python main.py <file>
BACKEND_MAIN_AUDIO_MODE = "auto"

# Queue / HTTP / WebSocket
BACKEND_QUEUE_MAX_SIZE = 100
BACKEND_HTTP_TIMEOUT_SECONDS = 300
BACKEND_WS_RECONNECT_SECONDS = 5
BACKEND_WS_PING_INTERVAL_SECONDS = 20
