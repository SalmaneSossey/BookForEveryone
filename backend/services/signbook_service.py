import re


SIGML_INDEX = {
    "كتاب": "alsl/كتاب.sigml",
    "الكتاب": "alsl/كتاب.sigml",
    "مكتبه": "alsl/مكتبة.sigml",
    "المكتبه": "alsl/مكتبة.sigml",
    "قراءة": "alsl/يقرأ.sigml",
    "قراءه": "alsl/يقرأ.sigml",
    "قرا": "alsl/يقرأ.sigml",
    "اقرا": "alsl/يقرأ.sigml",
    "تقرا": "alsl/يقرأ.sigml",
    "صوت": "alsl/صوت.sigml",
    "اشاره": "alsl/إشارة.sigml",
    "الاشاره": "alsl/إشارة.sigml",
    "اشارات": "alsl/إشارة.sigml",
    "كلمه": "alsl/كلمة.sigml",
    "كلمات": "alsl/كلمة.sigml",
    "الكلمات": "alsl/كلمة.sigml",
    "لغه": "alsl/لغة.sigml",
    "اللغه": "alsl/لغة.sigml",
    "يد": "alsl/يد.sigml",
    "يديها": "alsl/يد.sigml",
    "اليدين": "alsl/يد.sigml",
    "اطفال": "alsl/طفل.sigml",
    "الاطفال": "alsl/طفل.sigml",
    "صباح": "alsl/صباح.sigml",
    "story": "alsl/قصة.sigml",
    "book": "alsl/كتاب.sigml",
    "library": "alsl/مكتبة.sigml",
    "read": "alsl/يقرأ.sigml",
    "reading": "alsl/يقرأ.sigml",
    "learn": "alsl/يتعلم.sigml",
    "voice": "alsl/صوت.sigml",
    "word": "alsl/كلمة.sigml",
    "words": "alsl/كلمة.sigml",
    "sign": "alsl/إشارة.sigml",
    "gesture": "alsl/إشارة.sigml",
    "hands": "alsl/يد.sigml",
    "i": "cwasa_sample/i.sigml",
    "take": "cwasa_sample/take.sigml",
    "mug": "cwasa_sample/mug.sigml",
    "مرحبا": "alsl/مرحبا.sigml",
    "يقرأ": "alsl/يقرأ.sigml",
    "يقرا": "alsl/يقرأ.sigml",
    "كلمة": "alsl/كلمة.sigml",
    "شكرا": "alsl/شكرا.sigml",
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
