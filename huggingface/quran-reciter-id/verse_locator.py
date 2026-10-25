#!/usr/bin/env python3
"""Find the surah and ayah a recitation transcript is reading.

The index is the plain Quran in ``quran/ayahs.txt.gz`` (6,236 ayahs) plus
``quran/surahs.json``. Words are folded the same way as the app: diacritics
dropped, alef / ya / ta marbuta spelling variants collapsed.

A query votes with 3-, 4-, and 5-word grams, including grams that cross an
ayah boundary, so a clip longer than one verse returns a span. A phrase that
lands on several places equally (the repeated line in ar-Rahman, or the
basmalah alone) stays unknown.
"""

from __future__ import annotations

import gzip
import json
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

HERE = Path(__file__).resolve().parent
QURAN = HERE / "quran"
ASR_MODEL = "tarteel-ai/whisper-base-ar-quran"

_DIACRITICS = re.compile("[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]")
_NON_ARABIC = re.compile(r"[^\u0621-\u064A\s]")
_FOLDS = str.maketrans(
    {
        "أ": "ا",
        "إ": "ا",
        "آ": "ا",
        "ٱ": "ا",
        "ى": "ي",
        "ئ": "ي",
        "ة": "ه",
        "ؤ": "و",
    }
)
BISMILLAH = ("بسم", "الله", "الرحمن", "الرحيم")
# This checkpoint was trained on 30s clips and does not emit timestamp
# tokens. Whisper long-form decoding of a longer clip returns "".
_ASR_WINDOW = 30 * 16000


def fold_arabic(text: str) -> str:
    return _DIACRITICS.sub("", text).translate(_FOLDS)


def words_of(text: str) -> list[str]:
    folded = _NON_ARABIC.sub(" ", fold_arabic(text))
    return [w for w in folded.split() if len(w) >= 2]


@dataclass(frozen=True)
class VerseHit:
    surah: int
    ayah: int
    end_surah: int
    end_ayah: int
    name_ar: str
    name_en: str
    score: float
    matched_words: int

    def to_dict(self) -> dict:
        return {
            "surah": self.surah,
            "ayah": self.ayah,
            "end_surah": self.end_surah,
            "end_ayah": self.end_ayah,
            "name_ar": self.name_ar,
            "name_en": self.name_en,
            "score": round(self.score, 4),
            "matched_words": self.matched_words,
        }


class VerseLocator:
    def __init__(self, root: Path = QURAN) -> None:
        surahs = json.loads((root / "surahs.json").read_text())
        if len(surahs) != 114:
            raise ValueError(f"expected 114 surahs, got {len(surahs)}")
        self.surahs = surahs
        counts = [int(s["ayahs"]) for s in surahs]
        with gzip.open(root / "ayahs.txt.gz", "rt", encoding="utf-8") as handle:
            lines = [line.replace("\ufeff", "").strip() for line in handle]
        if len(lines) != 6236 or sum(counts) != 6236:
            raise ValueError(f"quran text has {len(lines)} lines")
        self._ayah_of: list[tuple[int, int]] = []
        self._words: list[str] = []
        ayah_i = 0
        for s, count in enumerate(counts, start=1):
            for n in range(1, count + 1):
                text = lines[ayah_i]
                ayah_i += 1
                if n == 1 and s not in (1, 9):
                    text = _strip_leading_bismillah(text)
                for word in words_of(text):
                    self._words.append(word)
                    self._ayah_of.append((s, n))
        if ayah_i != 6236:
            raise ValueError(f"walked {ayah_i} ayahs")
        self._index: dict[int, dict[tuple[str, ...], list[int]]] = {}
        for n in (3, 4, 5):
            table: dict[tuple[str, ...], list[int]] = defaultdict(list)
            for i in range(len(self._words) - n + 1):
                table[tuple(self._words[i : i + n])].append(i)
            self._index[n] = table

    def locate(self, transcript: str) -> VerseHit | None:
        words = words_of(transcript)
        if len(words) >= 7 and tuple(words[:4]) == BISMILLAH:
            words = words[4:]
        if len(words) < 3:
            return None
        preferred = 5 if len(words) >= 8 else 4 if len(words) >= 5 else 3
        widths = [preferred]
        for n in (4, 3):
            if n < preferred:
                widths.append(n)
        for width in widths:
            hit, status = self._align(words, width)
            # A tie is a real repeated phrase (ar-Rahman). A shorter gram
            # would only invent a winner. A weak or empty vote can be an
            # ASR miss, so try the next shorter gram.
            if status == "tie":
                return None
            if hit is not None:
                return hit
        return None

    def _align(self, words: list[str], width: int) -> tuple[VerseHit | None, str]:
        votes: Counter[int] = Counter()
        grams = 0
        for q in range(len(words) - width + 1):
            hits = self._index[width].get(tuple(words[q : q + width]))
            if not hits:
                continue
            grams += 1
            for pos in hits:
                votes[pos - q] += 1
        if grams == 0 or not votes:
            return None, "none"
        possible = len(words) - width + 1
        (start, best), *rest = votes.most_common()
        second = rest[0][1] if rest else 0
        if best < 1 or best == second:
            return None, "tie"
        # A clean clip matches most grams. A Whisper clip often keeps one
        # exact stretch and mangles the rest, so the share stays under 0.34.
        # Keep that hit when one place leads by at least two times.
        ratio = best / possible
        margin = best >= 3 and best >= second * 2
        if ratio < 0.34 and not margin:
            return None, "weak"
        if start < 0 or start >= len(self._words):
            return None, "none"
        end = min(len(self._words) - 1, start + len(words) - 1)
        surah, ayah = self._ayah_of[start]
        end_surah, end_ayah = self._ayah_of[end]
        meta = self.surahs[surah - 1]
        return (
            VerseHit(
                surah=surah,
                ayah=ayah,
                end_surah=end_surah,
                end_ayah=end_ayah,
                name_ar=meta["name_ar"],
                name_en=meta["name_en"],
                score=best / possible,
                matched_words=best,
            ),
            "ok",
        )


_asr = None


def transcribe(samples, sample_rate: int = 16000) -> str:
    """Arabic transcript from tarteel-ai/whisper-base-ar-quran.

    ``samples`` is a mono float32 waveform, or a path to a wav.
    The checkpoint is downloaded from the Hub on first use. It is not
    shipped in this repository.

    Each call is decoded in independent 30 second pieces. The checkpoint
    has no timestamp tokens, so the pipeline's long-form path (anything
    over 30 seconds) returns an empty string and the verse stays unknown.
    """
    audio = _as_16k(samples, sample_rate)
    if audio.size < 16000:
        return ""
    processor, model = _load_asr()
    import torch

    parts: list[str] = []
    for start in range(0, int(audio.shape[0]), _ASR_WINDOW):
        chunk = audio[start : start + _ASR_WINDOW]
        if chunk.shape[0] < 16000:
            break
        batch = processor(chunk, sampling_rate=16000, return_tensors="pt")
        with torch.inference_mode():
            ids = model.generate(batch.input_features)
        text = processor.batch_decode(ids, skip_special_tokens=True)[0].strip()
        if text:
            parts.append(text)
    return " ".join(parts)


def _load_asr():
    global _asr
    if _asr is None:
        from transformers import WhisperForConditionalGeneration, WhisperProcessor

        processor = WhisperProcessor.from_pretrained(ASR_MODEL)
        model = WhisperForConditionalGeneration.from_pretrained(ASR_MODEL)
        model.eval()
        _modernize_generation_config(model, processor)
        _asr = (processor, model)
    return _asr


def _modernize_generation_config(model, processor) -> None:
    """Fill lang/task token maps, then set Arabic transcription.

    This checkpoint was saved with transformers 4.26 and has no
    ``generation_config.json``. Setting ``language`` on that partial
    config makes current ``generate()`` raise "generation config is
    outdated". The maps live on the tokenizer; the base Whisper config
    is only fetched if those maps cannot be copied.
    """
    config = model.generation_config
    tokenizer = processor.tokenizer
    try:
        config.lang_to_id = dict(tokenizer.lang_to_id)
        config.task_to_id = dict(tokenizer.task_to_id)
        config.is_multilingual = True
        no_ts = getattr(tokenizer, "no_timestamps_token_id", None)
        if no_ts is not None:
            config.no_timestamps_token_id = no_ts
        if not hasattr(config, "lang_to_id") or not hasattr(config, "task_to_id"):
            raise AttributeError
    except (AttributeError, TypeError):
        from transformers import GenerationConfig

        config = GenerationConfig.from_pretrained("openai/whisper-base")
        model.generation_config = config
    config.forced_decoder_ids = None
    config.language = "ar"
    config.task = "transcribe"


def _as_16k(samples, sample_rate: int):
    import numpy as np

    if isinstance(samples, (str, Path)):
        import soundfile as sf

        data, sample_rate = sf.read(str(samples), always_2d=True, dtype="float32")
        audio = data.mean(axis=1) if data.shape[1] > 1 else data[:, 0]
    else:
        audio = np.asarray(samples, dtype=np.float32).reshape(-1)
    return _resample(np.ascontiguousarray(audio, dtype=np.float32), int(sample_rate), 16000)


def _resample(audio, src: int, dst: int):
    import numpy as np

    audio = np.asarray(audio, dtype=np.float32).reshape(-1)
    if src == dst or audio.size == 0:
        return np.ascontiguousarray(audio)
    new_len = int(round(audio.shape[0] * dst / src))
    if new_len < 2:
        return np.zeros(0, dtype=np.float32)
    source_x = np.linspace(0.0, 1.0, audio.shape[0], endpoint=False)
    target_x = np.linspace(0.0, 1.0, new_len, endpoint=False)
    return np.ascontiguousarray(np.interp(target_x, source_x, audio).astype(np.float32))


def _strip_leading_bismillah(text: str) -> str:
    words = text.split()
    folded = [fold_arabic(w) for w in words]
    if folded[:4] == list(BISMILLAH):
        return " ".join(words[4:])
    return text


def _self_test() -> None:
    loc = VerseLocator()
    one = loc.locate("إياك نعبد وإياك نستعين اهدنا الصراط المستقيم")
    if one is None or (one.surah, one.ayah, one.end_ayah) != (1, 5, 6):
        raise SystemExit(f"fatiha missed: {one}")
    ikhlas = loc.locate("قل هو الله أحد الله الصمد")
    if ikhlas is None or (ikhlas.surah, ikhlas.ayah) != (112, 1):
        raise SystemExit(f"ikhlas missed: {ikhlas}")
    if ikhlas.end_ayah < 2:
        raise SystemExit(f"ikhlas should cover the next ayah: {ikhlas}")
    marked = loc.locate("قُلْ هُوَ اللَّهُ أَحَدٌ. اللَّهُ الصَّمَدُ")
    if marked is None or (marked.surah, marked.ayah) != (112, 1):
        raise SystemExit(f"punctuation should still match ikhlas: {marked}")
    garbled = loc.locate("قل هو الله أحد الله خطأ لم يلد ولم يولد ولم يكن له كفوا أحد")
    if garbled is None or garbled.surah != 112:
        raise SystemExit(f"one wrong word should still land on ikhlas: {garbled}")
    saba = loc.locate(
        "وأننا لهم حديد أن اعمل سابغات وقتر في السرت واعملوا صالحا "
        "إني بما تعملون بصير ولسليمان اخريح غدوها شهر وروها شهر "
        "وأسلنا له عنا القتر ومن الجيقين إني من يعمل بين يديه"
    )
    if saba is None or (saba.surah, saba.ayah) != (34, 10):
        raise SystemExit(f"misheard saba should be 34:10: {saba}")
    repeated = loc.locate("فبأي آلاء ربكما تكذبان")
    if repeated is not None:
        raise SystemExit(f"repeated rahman line should be unknown: {repeated}")
    short = loc.locate("قل هو")
    if short is not None:
        raise SystemExit(f"two words should be unknown: {short}")
    print(
        f"ok ayah index {len(loc._ayah_of)} markers, "
        f"1:{one.ayah}-{one.end_ayah} {one.name_en}, "
        f"112:{ikhlas.ayah}-{ikhlas.end_ayah}"
    )


if __name__ == "__main__":
    _self_test()
