from fastapi import APIRouter

from models.schemas import TextToGlossRequest, TextToGlossResponse
from services.signbook_service import text_to_glosses

router = APIRouter(prefix="/api/signbook", tags=["signbook"])


@router.post(
    "/text-to-glosses",
    response_model=TextToGlossResponse,
    response_model_by_alias=True,
)
def convert_text_to_glosses(request: TextToGlossRequest) -> dict:
    return {"glosses": text_to_glosses(request.text)}
