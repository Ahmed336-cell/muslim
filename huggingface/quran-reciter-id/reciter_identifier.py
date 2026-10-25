#!/usr/bin/env python3
"""Closed-set Quran reciter identification.

Row ``i`` of ``embeddings.safetensors`` is the voiceprint for
``catalog.json["items"][i]``. Every row is an L2-normalized 192-d
vector from ``nemo_en_titanet_small.onnx``. A clip is named as the
nearest recording, the first candidate, even when the cosine is under 0.70.

The encoder weights are not in this folder. ``rank`` only needs a
vector. ``embed_wav`` needs sherpa-onnx and the ONNX file named in
``config.json``.

Examples:
  python reciter_identifier.py --self-test
  python reciter_identifier.py --wav clip.wav --encoder nemo_en_titanet_small.onnx
  python reciter_identifier.py --publish your-user/quran-reciter-id
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
ENCODER_NAME = "nemo_en_titanet_small.onnx"
# A 15 second clip is not long enough. The gallery was enrolled on 20 second
# clips, and the scorer averages 20 second windows from a 30 second take.
MIN_SECONDS = 20
WINDOW_SECONDS = 20
HOP_SECONDS = 10
LISTEN_SECONDS = 30


@dataclass(frozen=True)
class ReciterVoice:
    reciter_id: int
    recording_id: int
    name_ar: str
    name_en: str
    recording_name: str

    def name(self, language: str = "en") -> str:
        return self.name_ar if language == "ar" else self.name_en


@dataclass(frozen=True)
class Detection:
    matches: list
    reciter: "ReciterMatch | None"
    agreement: float
    windows: int
    seconds: float
    verse: object | None
    transcript: str

    def to_dict(self) -> dict:
        reciter = None if self.reciter is None else self.reciter.to_dict()
        verse = None if self.verse is None else self.verse.to_dict()
        return {
            "match": reciter,
            "unknown": self.reciter is None,
            "agreement": round(self.agreement, 4),
            "windows": self.windows,
            "seconds": round(self.seconds, 2),
            "threshold": None,
            "candidates": [m.to_dict() for m in self.matches],
            "verse": verse,
            "transcript": self.transcript,
        }


@dataclass(frozen=True)
class ReciterMatch:
    voice: ReciterVoice
    score: float

    def to_dict(self) -> dict:
        return {
            "reciter_id": self.voice.reciter_id,
            "recording_id": self.voice.recording_id,
            "name_ar": self.voice.name_ar,
            "name_en": self.voice.name_en,
            "recording_name": self.voice.recording_name,
            "score": round(self.score, 6),
        }


class ReciterIdentifier:
    """Gallery search. Same math as ``rankReciters`` in the Flutter app."""

    def __init__(
        self,
        embeddings: np.ndarray,
        voices: list[ReciterVoice],
        threshold: float = 0.70,
        top_k: int = 3,
    ) -> None:
        matrix = np.asarray(embeddings, dtype=np.float32)
        if matrix.ndim != 2:
            raise ValueError(f"embeddings must be 2-d, got {matrix.shape}")
        if matrix.shape[0] != len(voices):
            raise ValueError(
                f"{matrix.shape[0]} rows for {len(voices)} voices"
            )
        if matrix.shape[0] == 0 or matrix.shape[1] == 0:
            raise ValueError("gallery is empty")
        self.embeddings = np.ascontiguousarray(matrix)
        self.voices = list(voices)
        self.threshold = float(threshold)
        self.top_k = int(top_k)
        self.dim = int(matrix.shape[1])

    @property
    def reciters(self) -> int:
        return len({v.reciter_id for v in self.voices})

    @classmethod
    def from_pretrained(
        cls,
        repo_or_path: str | Path = HERE,
        *,
        revision: str | None = None,
        token: str | None = None,
    ) -> "ReciterIdentifier":
        root = _resolve(repo_or_path, revision=revision, token=token)
        config_path = root / "config.json"
        config = json.loads(config_path.read_text()) if config_path.is_file() else {}
        catalog = json.loads((root / "catalog.json").read_text())
        items = catalog["items"]
        voices = [
            ReciterVoice(
                reciter_id=int(item["reciterId"]),
                recording_id=int(item["recordingId"]),
                name_ar=str(item["nameAr"]),
                name_en=str(item["nameEn"]),
                recording_name=str(item["recordingName"]),
            )
            for item in items
        ]
        safetensors = root / "embeddings.safetensors"
        if safetensors.is_file():
            matrix = _load_safetensors(safetensors)
        else:
            dim = int(catalog.get("dim") or config.get("dim") or 0)
            raw = np.fromfile(root / "embeddings.bin", dtype=np.float32)
            if dim <= 0 or raw.size != len(voices) * dim:
                raise ValueError(
                    f"embeddings.bin has {raw.size} floats for {len(voices)} x {dim}"
                )
            matrix = raw.reshape(len(voices), dim)
        threshold = float(catalog.get("threshold") or config.get("threshold") or 0.70)
        top_k = int(catalog.get("top_k") or config.get("top_k") or 3)
        model = cls(matrix, voices, threshold=threshold, top_k=top_k)
        expected = int(catalog.get("dim") or config.get("dim") or model.dim)
        if model.dim != expected:
            raise ValueError(f"gallery dim {model.dim} != catalog dim {expected}")
        return model

    def rank(self, query: np.ndarray, k: int | None = None) -> list[ReciterMatch]:
        """Top cosine matches. Empty when ``query`` is silent or the wrong size."""
        vector = np.asarray(query, dtype=np.float32).reshape(-1)
        if vector.size != self.dim:
            raise ValueError(f"query dim {vector.size} != {self.dim}")
        norm = float(np.linalg.norm(vector))
        if norm == 0.0:
            return []
        scores = self.embeddings @ (vector / norm)
        take = self.top_k if k is None else int(k)
        take = max(0, min(take, scores.size))
        if take == 0:
            return []
        # argpartition is enough for top-k; sort that slice so order is exact.
        pick = np.argpartition(-scores, take - 1)[:take]
        order = pick[np.argsort(-scores[pick])]
        return [
            ReciterMatch(self.voices[int(i)], float(scores[int(i)]))
            for i in order
        ]

    def identify(
        self, query: np.ndarray, k: int | None = None
    ) -> tuple[list[ReciterMatch], ReciterMatch | None]:
        """Return ``(top_k, best)``. ``best`` is None when the top score is under the threshold."""
        matches = self.rank(query, k)
        if not matches or matches[0].score < self.threshold:
            return matches, None
        return matches, matches[0]

    def embed_waveform(
        self,
        waveform: np.ndarray,
        sample_rate: int,
        encoder_path: str | Path,
    ) -> list[np.ndarray]:
        """One unit vector per 20 second window. The clip must be longer than 15 seconds."""
        import sherpa_onnx

        audio = np.ascontiguousarray(np.asarray(waveform, dtype=np.float32).reshape(-1))
        chunks = _audio_windows(audio, sample_rate)
        encoder = Path(encoder_path)
        if not encoder.is_file():
            raise FileNotFoundError(encoder)
        extractor = sherpa_onnx.SpeakerEmbeddingExtractor(
            sherpa_onnx.SpeakerEmbeddingExtractorConfig(
                model=str(encoder),
                num_threads=1,
                debug=False,
            )
        )
        if extractor.dim != self.dim:
            raise ValueError(
                f"encoder dim {extractor.dim} != gallery dim {self.dim}. "
                "Use nemo_en_titanet_small.onnx."
            )
        vectors = [_embed_chunk(extractor, chunk, sample_rate) for chunk in chunks]
        return vectors

    def embed_wav(self, wav_path: str | Path, encoder_path: str | Path) -> np.ndarray:
        """Pooled unit vector for a wav of at least 20 seconds."""
        import soundfile as sf

        samples, sample_rate = sf.read(wav_path, always_2d=True, dtype="float32")
        waveform = np.ascontiguousarray(samples[:, 0])
        return pool_embeddings(
            self.embed_waveform(waveform, int(sample_rate), encoder_path)
        )

    def detect(
        self,
        waveform: np.ndarray,
        sample_rate: int,
        encoder_path: str | Path,
        transcript: str = "",
        k: int | None = None,
    ) -> Detection:
        """Reciter from windowed voiceprints, plus surah and ayah when a transcript is given.

        The named reciter is the first candidate, including when the cosine
        is under 0.70. The verse lookup does not need the encoder.
        """
        audio = np.ascontiguousarray(np.asarray(waveform, dtype=np.float32).reshape(-1))
        seconds = float(audio.shape[0] / sample_rate) if sample_rate else 0.0
        vectors = self.embed_waveform(audio, sample_rate, encoder_path)
        pooled = pool_embeddings(vectors)
        matches, best = self.identify(pooled, k)
        if best is None and matches:
            best = matches[0]
        agreement = 1.0
        if len(vectors) >= 2 and best is not None:
            ids = []
            for vector in vectors:
                top = self.rank(vector, k=1)
                ids.append(None if not top else top[0].voice.reciter_id)
            agreement = sum(i == best.voice.reciter_id for i in ids) / len(ids)
        verse = None
        text = transcript.strip()
        if text:
            from verse_locator import VerseLocator

            verse = VerseLocator().locate(text)
        return Detection(
            matches=matches,
            reciter=best,
            agreement=agreement,
            windows=len(vectors),
            seconds=seconds,
            verse=verse,
            transcript=text,
        )

    def identify_wav(
        self,
        wav_path: str | Path,
        encoder_path: str | Path,
        k: int | None = None,
        transcript: str = "",
    ) -> Detection:
        import soundfile as sf

        samples, sample_rate = sf.read(wav_path, always_2d=True, dtype="float32")
        waveform = np.ascontiguousarray(samples[:, 0])
        return self.detect(
            waveform, int(sample_rate), encoder_path, transcript=transcript, k=k
        )


def download_encoder(dest: str | Path, config_path: str | Path | None = None) -> Path:
    """Download the TitaNet ONNX file and check its sha256. Skip if the file is already valid."""
    dest = Path(dest)
    config_file = Path(config_path) if config_path else HERE / "config.json"
    config = json.loads(config_file.read_text())["encoder"]
    expected = str(config["sha256"])
    if dest.is_file() and _sha256(dest) == expected:
        return dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    url = str(config["url"])
    part = dest.with_suffix(dest.suffix + ".part")
    request = urllib.request.Request(url, headers={"User-Agent": "quran-reciter-id"})
    with urllib.request.urlopen(request, timeout=120) as response, part.open("wb") as out:
        while True:
            chunk = response.read(1 << 20)
            if not chunk:
                break
            out.write(chunk)
    digest = _sha256(part)
    if digest != expected:
        part.unlink(missing_ok=True)
        raise RuntimeError(f"encoder checksum {digest} != {expected}")
    part.replace(dest)
    return dest


def publish(repo_id: str, folder: str | Path = HERE, private: bool = False) -> str:
    """Create the model repo if needed and upload this folder.

    Requires ``HF_TOKEN`` or a prior ``huggingface-cli login``.
    ``repo_id`` is ``username/quran-reciter-id``.
    """
    from huggingface_hub import HfApi

    folder = Path(folder)
    api = HfApi()
    api.create_repo(
        repo_id=repo_id,
        repo_type="model",
        private=private,
        exist_ok=True,
    )
    commit = api.upload_folder(
        folder_path=str(folder),
        repo_id=repo_id,
        repo_type="model",
        commit_message="Publish the Quran reciter voiceprint gallery",
        ignore_patterns=["__pycache__", "*.pyc", ".DS_Store"],
    )
    return commit.commit_url or repo_id


def _resolve(
    repo_or_path: str | Path,
    *,
    revision: str | None,
    token: str | None,
) -> Path:
    path = Path(repo_or_path)
    if path.is_dir():
        if not (path / "catalog.json").is_file():
            raise FileNotFoundError(path / "catalog.json")
        return path
    from huggingface_hub import snapshot_download

    local = snapshot_download(
        repo_id=str(repo_or_path),
        revision=revision,
        token=token,
        allow_patterns=[
            "config.json",
            "catalog.json",
            "embeddings.safetensors",
            "embeddings.bin",
            "preprocessor_config.json",
            "quran/*",
            "verse_locator.py",
        ],
    )
    return Path(local)


def _load_safetensors(path: Path) -> np.ndarray:
    blob = path.read_bytes()
    if len(blob) < 8:
        raise ValueError(f"{path} is too small to be safetensors")
    header_size = struct.unpack_from("<Q", blob, 0)[0]
    header = json.loads(blob[8 : 8 + header_size])
    info = header["embeddings"]
    if info["dtype"] != "F32":
        raise ValueError(f"expected F32 embeddings, got {info['dtype']}")
    start, end = info["data_offsets"]
    base = 8 + header_size
    array = np.frombuffer(blob[base + start : base + end], dtype=np.float32)
    return np.array(array, dtype=np.float32).reshape(info["shape"])


def _audio_windows(waveform: np.ndarray, sample_rate: int) -> list[np.ndarray]:
    """20 second slices, hop 10. Anything of 15 seconds or less is refused."""
    audio = np.ascontiguousarray(waveform)
    duration = audio.shape[0] / sample_rate
    if duration < MIN_SECONDS:
        raise ValueError(
            f"clip is {duration:.1f}s. 15 seconds is not enough. "
            f"Pass at least {MIN_SECONDS} seconds. "
            f"{LISTEN_SECONDS} seconds is the length this model scores."
        )
    win = int(WINDOW_SECONDS * sample_rate)
    hop = int(HOP_SECONDS * sample_rate)
    if audio.shape[0] <= win:
        return [audio]
    chunks = []
    start = 0
    while start < audio.shape[0]:
        chunk = audio[start : start + win]
        if chunk.shape[0] > int(15 * sample_rate):
            chunks.append(np.ascontiguousarray(chunk))
        if start + win >= audio.shape[0]:
            break
        start += hop
    if not chunks:
        raise ValueError("no window longer than 15 seconds")
    return chunks


def pool_embeddings(vectors: list[np.ndarray]) -> np.ndarray:
    """Mean of unit vectors, then L2-normalize. Same pooling as enrollment."""
    units = []
    for vector in vectors:
        row = np.asarray(vector, dtype=np.float32).reshape(-1)
        norm = float(np.linalg.norm(row))
        if norm == 0.0:
            raise ValueError("zero embedding")
        units.append(row / norm)
    mean = np.mean(np.stack(units), axis=0)
    norm = float(np.linalg.norm(mean))
    if norm == 0.0:
        raise ValueError("zero embedding")
    return (mean / norm).astype(np.float32)


def _embed_chunk(extractor, chunk: np.ndarray, sample_rate: int) -> np.ndarray:
    stream = extractor.create_stream()
    stream.accept_waveform(sample_rate=sample_rate, waveform=chunk)
    stream.input_finished()
    if not extractor.is_ready(stream):
        raise ValueError("not enough audio in a window")
    vector = np.asarray(extractor.compute(stream), dtype=np.float32)
    norm = float(np.linalg.norm(vector))
    if norm == 0.0:
        raise ValueError("zero embedding")
    return vector / norm


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _self_test() -> None:
    model = ReciterIdentifier.from_pretrained(HERE)
    if model.embeddings.shape != (289, 192):
        raise SystemExit(f"unexpected shape {model.embeddings.shape}")
    if model.reciters != 243:
        raise SystemExit(f"unexpected reciters {model.reciters}")
    norms = np.linalg.norm(model.embeddings, axis=1)
    if not np.allclose(norms, 1.0, atol=1e-5):
        raise SystemExit("gallery rows are not unit vectors")
    first = model.voices[0]
    matches, best = model.identify(model.embeddings[0])
    if best is None or best.voice.recording_id != first.recording_id:
        raise SystemExit(f"self match failed: {matches[:1]}")
    if abs(best.score - 1.0) > 1e-5:
        raise SystemExit(f"self cosine {best.score}")
    if model.rank(np.zeros(model.dim, dtype=np.float32)):
        raise SystemExit("silence should match nobody")
    try:
        model.rank(np.ones(4, dtype=np.float32))
    except ValueError:
        pass
    else:
        raise SystemExit("wrong dim should fail")
    print(
        f"ok {len(model.voices)} voices, {model.reciters} reciters, "
        f"dim {model.dim}, threshold {model.threshold}"
    )
    print(
        f"self-match {best.voice.name_en} / {best.voice.recording_name} "
        f"{best.score:.6f}"
    )
    try:
        _audio_windows(np.zeros(15 * 16000, dtype=np.float32), 16000)
    except ValueError:
        pass
    else:
        raise SystemExit("15s clip should be refused")
    if len(_audio_windows(np.zeros(30 * 16000, dtype=np.float32), 16000)) != 2:
        raise SystemExit("30s clip should make two 20s windows")
    from verse_locator import _self_test as _verse_test

    _verse_test()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--wav", type=Path)
    parser.add_argument("--encoder", type=Path)
    parser.add_argument("--download-encoder", type=Path)
    parser.add_argument("--publish", metavar="USER/REPO")
    parser.add_argument("--private", action="store_true")
    parser.add_argument("--k", type=int, default=3)
    args = parser.parse_args()

    if args.download_encoder:
        path = download_encoder(args.download_encoder)
        print(path)
        return
    if args.publish:
        print(publish(args.publish, private=args.private))
        return
    if args.self_test or args.wav is None:
        _self_test()
        if args.wav is None:
            return
    if args.encoder is None:
        raise SystemExit("--wav needs --encoder path/to/nemo_en_titanet_small.onnx")
    model = ReciterIdentifier.from_pretrained(HERE)
    transcript = ""
    try:
        from verse_locator import transcribe

        transcript = transcribe(args.wav)
    except Exception as exc:  # noqa: BLE001 — verse is optional if ASR is not installed
        print(f"verse transcript skipped: {exc}")
    found = model.identify_wav(args.wav, args.encoder, k=args.k, transcript=transcript)
    for match in found.matches:
        flag = "MATCH" if found.reciter is not None and match is found.reciter else "    "
        print(f"{flag} {match.score:.3f}  {match.voice.name_en}  {match.voice.recording_name}")
    print(f"windows {found.windows}  agreement {found.agreement:.2f}  {found.seconds:.1f}s")
    if found.verse is None:
        print("verse unknown")
    else:
        verse = found.verse
        span = f"{verse.ayah}" if verse.end_ayah == verse.ayah else f"{verse.ayah}-{verse.end_ayah}"
        print(f"verse {verse.surah}:{span} {verse.name_en} {verse.name_ar}")
    if found.reciter is None:
        print("reciter unknown")
        sys.exit(2)


if __name__ == "__main__":
    main()
