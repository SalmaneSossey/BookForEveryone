import re


SIGML_INDEX = {
    "كتاب": "additions_lsm/kitab.sigml",
    "الكتاب": "additions_lsm/kitab.sigml",
    "مكتبه": "additions_lsm/library.sigml",
    "المكتبه": "additions_lsm/library.sigml",
    "قراءة": "additions_lsm/qiraa.sigml",
    "قراءه": "additions_lsm/qiraa.sigml",
    "قرا": "additions_lsm/qiraa.sigml",
    "اقرا": "additions_lsm/qiraa.sigml",
    "تقرا": "additions_lsm/qiraa.sigml",
    "أمل": "additions_lsm/amal.sigml",
    "امل": "additions_lsm/amal.sigml",
    "صوت": "additions_lsm/sawt.sigml",
    "حركة": "additions_lsm/haraka.sigml",
    "حركه": "additions_lsm/haraka.sigml",
    "اشاره": "additions_lsm/sign.sigml",
    "الاشاره": "additions_lsm/sign.sigml",
    "اشارات": "additions_lsm/sign.sigml",
    "كلمه": "additions_lsm/word.sigml",
    "كلمات": "additions_lsm/word.sigml",
    "الكلمات": "additions_lsm/word.sigml",
    "لغه": "additions_lsm/language.sigml",
    "اللغه": "additions_lsm/language.sigml",
    "الجميع": "additions_lsm/everyone.sigml",
    "كل": "additions_lsm/everyone.sigml",
    "يد": "additions_lsm/hand.sigml",
    "يديها": "additions_lsm/hand.sigml",
    "اليدين": "additions_lsm/hand.sigml",
    "صوره": "additions_lsm/image.sigml",
    "صور": "additions_lsm/image.sigml",
    "المعنى": "additions_lsm/meaning.sigml",
    "معنى": "additions_lsm/meaning.sigml",
    "اطفال": "additions_lsm/children.sigml",
    "الاطفال": "additions_lsm/children.sigml",
    "ساميه": "additions_lsm/samia.sigml",
    "صباح": "additions_lsm/morning.sigml",
    "story": "additions_lsm/story.sigml",
    "book": "additions_lsm/book.sigml",
    "library": "additions_lsm/library.sigml",
    "read": "additions_lsm/read.sigml",
    "reading": "additions_lsm/read.sigml",
    "learn": "additions_lsm/learn.sigml",
    "voice": "additions_lsm/voice.sigml",
    "word": "additions_lsm/word.sigml",
    "words": "additions_lsm/word.sigml",
    "sign": "additions_lsm/sign.sigml",
    "gesture": "additions_lsm/sign.sigml",
    "hands": "additions_lsm/hand.sigml",
    "i": "cwasa_sample/i.sigml",
    "take": "cwasa_sample/take.sigml",
    "mug": "cwasa_sample/mug.sigml",
    "video": "cwasa_story/blenderStory.sigml",
    "exciting": "cwasa_story/blenderStory.sigml",
    "see": "cwasa_story/blenderStory.sigml",
    "woman": "cwasa_story/blenderStory.sigml",
    "four": "cwasa_story/blenderStory.sigml",
    "friend": "cwasa_story/blenderStory.sigml",
    "friends": "cwasa_story/blenderStory.sigml",
    "cook": "cwasa_story/blenderStory.sigml",
    "soup": "cwasa_story/blenderStory.sigml",
    "orange": "cwasa_story/blenderStory.sigml",
    "blender": "cwasa_story/blenderStory.sigml",
    "put": "cwasa_story/blenderStory.sigml",
    "explode": "cwasa_story/blenderStory.sigml",
    "explodes": "cwasa_story/blenderStory.sigml",
}


def text_to_glosses(text: str) -> list[dict[str, object]]:
    words = [_clean(word) for word in text.split()]
    glosses = []
    for word in [word for word in words if word][:18]:
        gloss = _normalize_arabic(word.lower())
        sigml_path = _resolve_sigml_path(gloss)
        glosses.append(
            {
                "word": word,
                "gloss": gloss,
                "available": sigml_path is not None,
                "sigmlPath": sigml_path,
            }
        )
    return glosses


def _clean(word: str) -> str:
    return re.sub(r"[^\w\u0600-\u06FF]+", "", word)


def _normalize_arabic(value: str) -> str:
    value = re.sub(r"[\u064B-\u065F\u0670]", "", value)
    return value.replace("أ", "ا").replace("إ", "ا").replace("آ", "ا").replace("ة", "ه")


def _resolve_sigml_path(key: str) -> str | None:
    for candidate in _candidates(key):
        if candidate in SIGML_INDEX:
            return SIGML_INDEX[candidate]
    return None


def _candidates(key: str) -> list[str]:
    bases = [key]
    if key.startswith("و") and len(key) > 3:
        bases.append(key[1:])

    candidates = []
    for base in bases:
        candidates.append(base)
        if base.startswith("ال") and len(base) > 3:
            candidates.append(base[2:])

        for suffix in ["ها", "هم", "كم", "نا", "ات", "ين", "ون", "ه", "ي", "ا"]:
            if base.endswith(suffix) and len(base) > len(suffix) + 2:
                without_suffix = base[: -len(suffix)]
                candidates.append(without_suffix)
                if without_suffix.startswith("ال") and len(without_suffix) > 3:
                    candidates.append(without_suffix[2:])

    return candidates
