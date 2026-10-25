"""Hugging Face Inference Endpoints handler.

The endpoint folder is this model repo. On startup the handler
downloads ``nemo_en_titanet_small.onnx`` next to the gallery and
checks the sha256 in ``config.json``.

Request JSON:
  {"inputs": "<base64 wav or base64 pcm16 mono 16 kHz>"}
  {"inputs": {"audio": "<base64>", "format": "wav"|"pcm16"}}

A clip of 15 seconds or less is refused. 20 seconds is the minimum.
30 seconds is the length the voice windows are built for.

Response JSON:
  {
    "match": {voice fields, "score"} or null,
    "unknown": true/false,
    "agreement": 0.0 to 1.0,
    "windows": 2,
    "seconds": 30.0,
    "threshold": 0.7,
    "candidates": [up to 3 matches],
    "verse": {surah, ayah, end_ayah, name_ar, name_en, score} or null,
    "transcript": "..."
  }
"""

from __future__ import annotations

import base64
import io
from typing import Any

import numpy as np

from reciter_identifier import ReciterIdentifier, download_encoder
from verse_locator import VerseLocator, transcribe


class EndpointHandler:
    def __init__(self, path: str = "") -> None:
        root = path or "."
        self.model = ReciterIdentifier.from_pretrained(root)
        self.encoder = download_encoder(f"{root}/nemo_en_titanet_small.onnx")

    def __call__(self, data: dict[str, Any]) -> dict[str, Any]:
        inputs = data.get("inputs", data)
        given = ""
        if isinstance(inputs, dict):
            given = str(inputs.get("transcript") or "")
        if isinstance(inputs, dict) and not any(k in inputs for k in ("audio", "inputs")):
            if not given and isinstance(inputs.get("text"), str):
                given = inputs["text"]
            verse = VerseLocator().locate(given) if given else None
            return {
                "match": None,
                "unknown": True,
                "threshold": self.model.threshold,
                "candidates": [],
                "verse": None if verse is None else verse.to_dict(),
                "transcript": given,
            }
        samples = _decode_audio(inputs)
        transcript = given
        asr_error = None
        if not transcript:
            try:
                transcript = transcribe(samples, 16000)
            except Exception as exc:  # noqa: BLE001 — reciter result still stands
                asr_error = str(exc)
        try:
            found = self.model.detect(samples, 16000, self.encoder, transcript)
        except ValueError as exc:
            verse = VerseLocator().locate(transcript) if transcript else None
            return {
                "error": str(exc),
                "match": None,
                "unknown": True,
                "threshold": self.model.threshold,
                "candidates": [],
                "verse": None if verse is None else verse.to_dict(),
                "transcript": transcript,
            }
        body = found.to_dict()
        body["threshold"] = self.model.threshold
        if asr_error:
            body["asr_error"] = asr_error
        return body


def _decode_audio(inputs: Any) -> np.ndarray:
    if isinstance(inputs, dict):
        raw = _b64(inputs.get("audio") or inputs.get("inputs"))
        kind = str(inputs.get("format") or "wav")
    elif isinstance(inputs, str):
        raw = _b64(inputs)
        kind = "wav" if raw[:4] == b"RIFF" else "pcm16"
    else:
        raise ValueError("inputs must be base64 audio or {audio, format}")
    if kind == "pcm16":
        view = np.frombuffer(raw, dtype="<i2").astype(np.float32)
        return view / 32768.0
    import soundfile as sf

    samples, sample_rate = sf.read(io.BytesIO(raw), always_2d=True, dtype="float32")
    waveform = np.ascontiguousarray(samples[:, 0])
    if sample_rate != 16000:
        raise ValueError(f"wav sample rate {sample_rate}, expected 16000")
    return waveform


def _b64(value: Any) -> bytes:
    if not isinstance(value, str) or not value:
        raise ValueError("missing base64 audio")
    payload = value.split(",", 1)[1] if value.startswith("data:") else value
    return base64.b64decode(payload)
