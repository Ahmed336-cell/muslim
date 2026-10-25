#!/usr/bin/env python3
"""Build on-device reciter voiceprints from mp3quran.net.

Uses the same TitaNet ONNX file the Flutter app runs, so the embeddings
match. WeSpeaker's smaller model collapsed different reciters together;
TitaNet kept them apart on a held-out surah.

Every riwayah from ``/api/v3/riwayat`` is walked, then recent reads, then
the full reciter list, so a new voice is enrolled even when it only shows
up under one riwayah. Six surahs per recording, two 20-second windows
each when the file is long enough, are averaged into one vector. Safe to
stop and run again: a recording is skipped once those windows are stored.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import threading
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import numpy as np
import sherpa_onnx
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
MODEL_NAME = "nemo_en_titanet_small.onnx"
MODEL_URL = (
    "https://github.com/k2-fsa/sherpa-onnx/releases/download/"
    "speaker-recongition-models/" + MODEL_NAME
)
API = "https://www.mp3quran.net/api/v3/reciters"
RIWAYAT_API = "https://www.mp3quran.net/api/v3/riwayat"
RECENT_API = "https://www.mp3quran.net/api/v3/recent_reads"
OUT_DIR = ROOT / "assets" / "reciter_id"
HUB_DIR = ROOT / "huggingface" / "quran-reciter-id"
MODEL_PATH = Path(__file__).resolve().parent / "models" / MODEL_NAME
CACHE = Path(__file__).resolve().parent / "cache"
SOURCES = CACHE / "sources.json"
# Popular ids in the app, enrolled first so a partial catalog is useful.
POPULAR = {123, 51, 118, 112, 102, 92, 30, 31, 178, 5, 4, 86}
# Six surahs. The probe list is the ones left out, so a check is not
# the same audio the voiceprint was built from.
PREFERRED = [67, 78, 36, 55, 18, 19]
PROBE_SURAHS = [20, 56, 59, 76, 34, 32]
ENROLL_COUNT = 6
# Second window uses the rest of the same partial download.
WINDOWS = (8, 30)
RANGE_BYTES = 2_000_000
CLIP_START = 8
CLIP_SECONDS = 20
MIN_SECONDS = 8
UA = "muslim-reciter-id"


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as res:
        body = json.load(res)
    if not isinstance(body, dict):
        raise RuntimeError(f"expected object from {url}")
    return body


def fetch_reciters(language: str) -> list[dict]:
    url = f"{API}?language={'ar' if language == 'ar' else 'eng'}"
    return list(fetch_json(url).get("reciters") or [])


def pick_surahs(available: set[int], n: int = ENROLL_COUNT) -> list[int]:
    chosen = [s for s in PREFERRED if s in available]
    if len(chosen) < n:
        rest = sorted(s for s in available if s not in chosen and s < 100)
        chosen.extend(rest)
    if not chosen and available:
        chosen = sorted(available)
    return chosen[:n]


def download_head(url: str, dest: Path) -> None:
    if dest.exists() and dest.stat().st_size > 100_000:
        return
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": UA,
            "Range": f"bytes=0-{RANGE_BYTES - 1}",
            "Accept-Encoding": "identity",
        },
    )
    part = dest.with_suffix(dest.suffix + ".part")
    with urllib.request.urlopen(req, timeout=60) as res, part.open("wb") as out:
        remaining = RANGE_BYTES
        while remaining > 0:
            chunk = res.read(min(64 * 1024, remaining))
            if not chunk:
                break
            out.write(chunk)
            remaining -= len(chunk)
    part.replace(dest)


def to_wav(src: Path, dest: Path, start: int = CLIP_START) -> bool:
    if dest.exists() and dest.stat().st_size >= int(MIN_SECONDS * 16000 * 2):
        return True
    dest.parent.mkdir(parents=True, exist_ok=True)
    ffmpeg = shutil.which("ffmpeg")
    if ffmpeg is None:
        raise RuntimeError("ffmpeg is not installed")

    def run(args: list[str]) -> None:
        subprocess.run(args, check=True, capture_output=True)

    def cut(at: int) -> bool:
        try:
            run(
                [
                    ffmpeg,
                    "-hide_banner",
                    "-loglevel",
                    "error",
                    "-y",
                    "-i",
                    str(src),
                    "-ss",
                    str(at),
                    "-t",
                    str(CLIP_SECONDS),
                    "-ac",
                    "1",
                    "-ar",
                    "16000",
                    str(dest),
                ]
            )
        except subprocess.CalledProcessError:
            dest.unlink(missing_ok=True)
            return False
        return dest.exists() and dest.stat().st_size >= int(MIN_SECONDS * 16000 * 2)

    if cut(start):
        return True
    # Only the first window may fall back to the opening. The later
    # window would otherwise copy the same 20 seconds twice.
    if start != CLIP_START:
        dest.unlink(missing_ok=True)
        return False
    return cut(0)


def embed_file(extractor: sherpa_onnx.SpeakerEmbeddingExtractor, path: Path) -> np.ndarray:
    samples, sample_rate = sf.read(path, always_2d=True, dtype="float32")
    stream = extractor.create_stream()
    stream.accept_waveform(
        sample_rate=sample_rate, waveform=np.ascontiguousarray(samples[:, 0])
    )
    stream.input_finished()
    if not extractor.is_ready(stream):
        raise RuntimeError(f"not enough audio in {path}")
    vec = np.array(extractor.compute(stream), dtype=np.float32)
    norm = np.linalg.norm(vec)
    if norm == 0:
        raise RuntimeError(f"zero embedding for {path}")
    return vec / norm


def load_catalog() -> tuple[int, dict[str, dict]]:
    meta_path = OUT_DIR / "catalog.json"
    bin_path = OUT_DIR / "embeddings.bin"
    if not meta_path.exists() or not bin_path.exists():
        return 0, {}
    meta = json.loads(meta_path.read_text())
    dim = int(meta.get("dim") or 0)
    items = meta.get("items") or []
    if dim == 0 or not items:
        return dim, {}
    raw = np.fromfile(bin_path, dtype=np.float32)
    if raw.size != len(items) * dim:
        raise RuntimeError(
            f"catalog mismatch: {raw.size} floats for {len(items)} x {dim}"
        )
    found = {}
    for i, item in enumerate(items):
        key = f"{item['reciterId']}:{item['recordingId']}"
        found[key] = {**item, "embedding": raw[i * dim : (i + 1) * dim]}
    return dim, found


def save_catalog(items: list[dict], dim: int) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    mat = (
        np.stack([it["embedding"] for it in items]).astype(np.float32)
        if items
        else np.zeros((0, dim), dtype=np.float32)
    )
    meta = {
        "model": MODEL_NAME,
        "dim": dim if items else 0,
        "items": [
            {
                "reciterId": it["reciterId"],
                "recordingId": it["recordingId"],
                "nameAr": it["nameAr"],
                "nameEn": it["nameEn"],
                "recordingName": it["recordingName"],
            }
            for it in items
        ],
    }
    tmp_json = OUT_DIR / "catalog.json.tmp"
    tmp_bin = OUT_DIR / "embeddings.bin.tmp"
    tmp_json.write_text(json.dumps(meta, ensure_ascii=False))
    mat.tofile(tmp_bin)
    tmp_json.replace(OUT_DIR / "catalog.json")
    tmp_bin.replace(OUT_DIR / "embeddings.bin")


def _add_recordings(reciters: list[dict], jobs: dict[str, dict], english: dict) -> None:
    for rec in reciters:
        rid = int(rec["id"])
        en = english.get(rid, {})
        name_ar = str(rec.get("name") or "").strip()
        name_en = str(en.get("name") or name_ar).strip()
        en_moshafs = {m["id"]: m for m in en.get("moshaf") or []}
        for m in rec.get("moshaf") or []:
            key = f"{rid}:{m['id']}"
            if key in jobs:
                continue
            surahs = {
                int(s)
                for s in str(m.get("surah_list") or "").split(",")
                if s.strip().isdigit()
            }
            chosen = pick_surahs(surahs)
            server = str(m.get("server") or "")
            if not chosen or not server:
                continue
            if not server.endswith("/"):
                server += "/"
            en_m = en_moshafs.get(m["id"], {})
            jobs[key] = {
                "reciterId": rid,
                "recordingId": int(m["id"]),
                "nameAr": name_ar,
                "nameEn": name_en,
                "recordingName": str(m.get("name") or en_m.get("name") or "").strip(),
                "server": server,
                "surahs": chosen,
                "available": surahs,
                "rewayaId": m.get("rewaya_id"),
            }


def jobs_from_api(limit: int | None) -> list[dict]:
    """Riwayat first, then recent reads, then the full list.

    A recording is kept once. The riwayah walk is what picks up a voice
    that the API files under ``rewaya`` and not only on the flat list.
    """
    english = {r["id"]: r for r in fetch_reciters("eng")}
    jobs: dict[str, dict] = {}
    riwayat = fetch_json(f"{RIWAYAT_API}?language=ar").get("riwayat") or []
    print(f"riwayat {len(riwayat)}")
    for row in riwayat:
        body = fetch_json(f"{API}?language=ar&rewaya={int(row['id'])}")
        before = len(jobs)
        _add_recordings(list(body.get("reciters") or []), jobs, english)
        print(f"  {row['id']} {row.get('name')} +{len(jobs) - before}")
    recent = fetch_json(f"{RECENT_API}?language=ar").get("reads") or []
    before = len(jobs)
    _add_recordings(list(recent), jobs, english)
    print(f"recent reads {len(recent)} +{len(jobs) - before}")
    before = len(jobs)
    _add_recordings(fetch_reciters("ar"), jobs, english)
    print(f"full list +{len(jobs) - before}")
    ordered = sorted(
        jobs.values(),
        key=lambda j: (
            0 if j["reciterId"] in POPULAR else 1,
            j["nameEn"].lower(),
            j["recordingId"],
        ),
    )
    if limit is not None:
        ordered = ordered[:limit]
    return ordered


def load_sources() -> dict[str, dict]:
    if not SOURCES.is_file():
        return {}
    raw = json.loads(SOURCES.read_text())
    found = {}
    for key, value in raw.items():
        if isinstance(value, dict):
            found[str(key)] = value
        else:
            found[str(key)] = {"wanted": list(value), "got": list(value)}
    return found


def save_sources(sources: dict[str, list[str]]) -> None:
    SOURCES.parent.mkdir(parents=True, exist_ok=True)
    tmp = SOURCES.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(sources, ensure_ascii=False, sort_keys=True))
    tmp.replace(SOURCES)


def planned_sources(job: dict) -> list[str]:
    return [f"{surah}@{start}" for surah in job["surahs"] for start in WINDOWS]


def build(args: argparse.Namespace) -> None:
    if not MODEL_PATH.is_file():
        raise SystemExit(f"missing model: {MODEL_PATH}")
    extractor = sherpa_onnx.SpeakerEmbeddingExtractor(
        sherpa_onnx.SpeakerEmbeddingExtractorConfig(
            model=str(MODEL_PATH),
            num_threads=1,
            debug=False,
        )
    )
    dim, done = load_catalog()
    if dim and dim != extractor.dim:
        raise SystemExit(f"catalog dim {dim} != model dim {extractor.dim}")
    dim = extractor.dim
    sources = load_sources()
    pending = jobs_from_api(args.limit)
    todo = []
    for job in pending:
        key = f"{job['reciterId']}:{job['recordingId']}"
        row = sources.get(key) or {}
        if key in done and list(row.get("wanted") or []) == planned_sources(job):
            continue
        todo.append(job)
    print(
        f"model dim {dim}; cached {len(done)}; "
        f"to do {len(todo)} / {len(pending)}"
    )
    embed_lock = threading.Lock()
    save_lock = threading.Lock()

    def work(job: dict) -> dict | None:
        key = f"{job['reciterId']}:{job['recordingId']}"
        vectors = []
        got: list[str] = []
        for surah in job["surahs"]:
            mp3 = CACHE / "mp3" / f"{job['recordingId']}_{surah:03d}.mp3"
            url = f"{job['server']}{surah:03d}.mp3"
            try:
                download_head(url, mp3)
            except Exception as exc:  # noqa: BLE001 — keep the batch going
                print(f"skip {key} surah {surah}: {exc}")
                continue
            for start in WINDOWS:
                tag = f"{surah}@{start}"
                wav = CACHE / "wav" / f"{job['recordingId']}_{surah:03d}_{start}.wav"
                try:
                    if not to_wav(mp3, wav, start):
                        continue
                    with embed_lock:
                        vectors.append(embed_file(extractor, wav))
                    got.append(tag)
                except Exception as exc:  # noqa: BLE001 — keep the batch going
                    print(f"skip {key} {tag}: {exc}")
        if not vectors:
            print(f"fail {key} {job['nameEn']}")
            return None
        vec = np.mean(vectors, axis=0)
        vec = vec / np.linalg.norm(vec)
        print(f"ok {key} {job['nameEn']} ({len(vectors)} clips)")
        return {
            "reciterId": job["reciterId"],
            "recordingId": job["recordingId"],
            "nameAr": job["nameAr"],
            "nameEn": job["nameEn"],
            "recordingName": job["recordingName"],
            "embedding": vec.astype(np.float32),
            "sources": got,
            "wanted": planned_sources(job),
        }

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = [pool.submit(work, job) for job in todo]
        for fut in as_completed(futures):
            item = fut.result()
            if item is None:
                continue
            key = f"{item['reciterId']}:{item['recordingId']}"
            with save_lock:
                sources[key] = {
                    "wanted": list(item.get("wanted") or []),
                    "got": list(item.get("sources") or []),
                }
                done[key] = item
                ordered = sorted(
                    done.values(),
                    key=lambda it: (
                        0 if it["reciterId"] in POPULAR else 1,
                        it["nameEn"].lower(),
                        it["recordingId"],
                    ),
                )
                save_catalog(ordered, dim)
                save_sources(sources)
    print(f"wrote {len(done)} voiceprints to {OUT_DIR}")
    export_hub(ordered_catalog(done), dim)


def ordered_catalog(done: dict[str, dict]) -> list[dict]:
    return sorted(
        done.values(),
        key=lambda it: (
            0 if it["reciterId"] in POPULAR else 1,
            it["nameEn"].lower(),
            it["recordingId"],
        ),
    )


def export_hub(items: list[dict], dim: int) -> None:
    """Copy the gallery next to the Hugging Face model card."""
    if not items:
        return
    HUB_DIR.mkdir(parents=True, exist_ok=True)
    save_catalog(items, dim)
    # save_catalog writes the app assets. Copy those bytes to the hub folder.
    bin_src = OUT_DIR / "embeddings.bin"
    json_src = OUT_DIR / "catalog.json"
    (HUB_DIR / "embeddings.bin").write_bytes(bin_src.read_bytes())
    (HUB_DIR / "catalog.json").write_text(json_src.read_text())
    matrix = np.fromfile(bin_src, dtype=np.float32).reshape(len(items), dim)
    _write_safetensors(HUB_DIR / "embeddings.safetensors", matrix)
    print(f"copied {len(items)} voiceprints to {HUB_DIR}")


def _write_safetensors(path: Path, matrix: np.ndarray) -> None:
    import struct

    data = np.ascontiguousarray(matrix, dtype=np.float32).tobytes()
    header = {
        "embeddings": {
            "dtype": "F32",
            "shape": [int(matrix.shape[0]), int(matrix.shape[1])],
            "data_offsets": [0, len(data)],
        }
    }
    raw = json.dumps(header, separators=(",", ":")).encode()
    raw += b" " * ((8 - len(raw) % 8) % 8)
    path.write_bytes(struct.pack("<Q", len(raw)) + raw + data)


def probe(args: argparse.Namespace) -> None:
    dim, done = load_catalog()
    if not done:
        raise SystemExit("catalog is empty")
    extractor = sherpa_onnx.SpeakerEmbeddingExtractor(
        sherpa_onnx.SpeakerEmbeddingExtractorConfig(
            model=str(MODEL_PATH), num_threads=1, debug=False
        )
    )
    by_recording = {}
    for rec in fetch_reciters("ar"):
        for m in rec.get("moshaf") or []:
            surahs = {
                int(s)
                for s in str(m.get("surah_list") or "").split(",")
                if s.strip().isdigit()
            }
            server = str(m.get("server") or "")
            if server and not server.endswith("/"):
                server += "/"
            by_recording[m["id"]] = (server, surahs, rec["id"], str(rec["name"]))
    # Spread the probe across sheikhs. Same-voice recordings of one
    # reciter are not a fair test of "who is this".
    seen: set[int] = set()
    items = []
    for item in done.values():
        if item["reciterId"] in seen:
            continue
        seen.add(item["reciterId"])
        items.append(item)
        if len(items) == args.probe:
            break
    matrix = np.stack([it["embedding"] for it in done.values()])
    keys = list(done.keys())
    exact = 0
    same_reciter = 0
    tried = 0
    for item in items:
        server, surahs, rid, name = by_recording[item["recordingId"]]
        enrolled = set(pick_surahs(surahs))
        probe_surah = next(
            (s for s in PROBE_SURAHS if s in surahs and s not in enrolled),
            None,
        )
        if probe_surah is None:
            print(f"no probe surah for {name}")
            continue
        mp3 = CACHE / "probe" / f"{item['recordingId']}_{probe_surah:03d}.mp3"
        wav = CACHE / "probe" / f"{item['recordingId']}_{probe_surah:03d}.wav"
        download_head(f"{server}{probe_surah:03d}.mp3", mp3)
        if not to_wav(mp3, wav):
            print(f"probe clip failed for {name}")
            continue
        query = embed_file(extractor, wav)
        scores = matrix @ query
        best = int(np.argmax(scores))
        top = done[keys[best]]
        tried += 1
        exact += int(keys[best] == f"{item['reciterId']}:{item['recordingId']}")
        person = top["reciterId"] == item["reciterId"]
        same_reciter += int(person)
        print(
            f"{'HIT' if person else 'MISS'} {name} -> {top['nameEn']} "
            f"{top['recordingName']} {scores[best]:.3f} (surah {probe_surah})"
        )
    print(f"reciter {same_reciter}/{tried}, exact recording {exact}/{tried}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--workers", type=int, default=6)
    parser.add_argument(
        "--probe",
        type=int,
        default=0,
        help="Test this many catalog entries on a surah that was not enrolled",
    )
    args = parser.parse_args()
    if args.probe:
        probe(args)
    else:
        build(args)


if __name__ == "__main__":
    main()
