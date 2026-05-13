import re


SIGML_INDEX = {
    "كتاب": "additions_lsm/kitab.sigml",
    "الكتاب": "additions_lsm/kitab.sigml",
    "قراءة": "additions_lsm/qiraa.sigml",
    "قراءه": "additions_lsm/qiraa.sigml",
    "أمل": "additions_lsm/amal.sigml",
    "امل": "additions_lsm/amal.sigml",
    "صوت": "additions_lsm/sawt.sigml",
    "حركة": "additions_lsm/haraka.sigml",
    "حركه": "additions_lsm/haraka.sigml",
    "story": "additions_lsm/story.sigml",
    "book": "additions_lsm/book.sigml",
    "read": "additions_lsm/read.sigml",
    "reading": "additions_lsm/read.sigml",
    "learn": "additions_lsm/learn.sigml",
}


def text_to_glosses(text: str) -> list[dict[str, object]]:
    words = [_clean(word) for word in text.split()]
    glosses = []
    for word in [word for word in words if word][:18]:
        gloss = _normalize_arabic(word.lower())
        sigml_path = SIGML_INDEX.get(gloss)
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
