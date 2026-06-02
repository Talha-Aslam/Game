from fastapi import APIRouter, Depends
from app.middleware.auth_middleware import get_current_user
from app.services.family_service import (
    create_family, get_family, search_families, leave_family,
    update_family_settings, kick_member, promote_member, demote_member,
    donate_to_treasury, send_chat_message, get_chat_messages,
    apply_to_family, handle_application,
)
from pydantic import BaseModel
from typing import Optional


router = APIRouter(prefix="/family", tags=["Family"])


class CreateFamilyRequest(BaseModel):
    name: str
    tag: str
    description: str = ""
    slogan: str = ""
    privacy: str = "approvalRequired"


class UpdateSettingsRequest(BaseModel):
    name: Optional[str] = None
    tag: Optional[str] = None
    description: Optional[str] = None
    slogan: Optional[str] = None
    motd: Optional[str] = None
    privacy: Optional[str] = None


class DonateRequest(BaseModel):
    amount: int


class ChatMessageRequest(BaseModel):
    content: str


class ApplyRequest(BaseModel):
    message: str = ""
    is_invite: bool = False


@router.post("/create")
async def create(req: CreateFamilyRequest, user: dict = Depends(get_current_user)):
    return await create_family(
        user["_id"], req.name, req.tag, req.description, req.slogan, req.privacy
    )


@router.get("/me")
async def my_family(user: dict = Depends(get_current_user)):
    family = await get_family(user["_id"])
    if not family:
        return None
    return family


@router.get("/search")
async def search(query: str = ""):
    return await search_families(query)


@router.post("/leave")
async def leave(user: dict = Depends(get_current_user)):
    return await leave_family(user["_id"])


@router.delete("/delete")
async def delete_family_route(user: dict = Depends(get_current_user)):
    from app.services.family_service import delete_family
    return await delete_family(user["_id"])


@router.put("/settings")
async def settings(req: UpdateSettingsRequest, user: dict = Depends(get_current_user)):
    return await update_family_settings(user["_id"], req.model_dump(exclude_none=True))


@router.post("/kick/{target_user_id}")
async def kick(target_user_id: str, user: dict = Depends(get_current_user)):
    return await kick_member(user["_id"], target_user_id)


@router.post("/promote/{target_user_id}")
async def promote(target_user_id: str, user: dict = Depends(get_current_user)):
    return await promote_member(user["_id"], target_user_id)


@router.post("/demote/{target_user_id}")
async def demote(target_user_id: str, user: dict = Depends(get_current_user)):
    return await demote_member(user["_id"], target_user_id)


@router.post("/mute/{target_user_id}")
async def mute(target_user_id: str, user: dict = Depends(get_current_user)):
    from app.services.family_service import mute_member
    return await mute_member(user["_id"], target_user_id)


@router.post("/treasury/donate")
async def donate(req: DonateRequest, user: dict = Depends(get_current_user)):
    return await donate_to_treasury(user["_id"], req.amount)


@router.get("/chat")
async def chat_messages(user: dict = Depends(get_current_user)):
    return await get_chat_messages(user["_id"])


@router.post("/chat")
async def send_chat(req: ChatMessageRequest, user: dict = Depends(get_current_user)):
    return await send_chat_message(user["_id"], req.content)


@router.post("/apply/{family_id}")
async def apply(family_id: str, req: ApplyRequest, user: dict = Depends(get_current_user)):
    return await apply_to_family(user["_id"], family_id, req.message, req.is_invite)


@router.post("/applications/{app_id}/accept")
async def accept_app(app_id: str, user: dict = Depends(get_current_user)):
    return await handle_application(user["_id"], app_id, accept=True)


@router.post("/applications/{app_id}/reject")
async def reject_app(app_id: str, user: dict = Depends(get_current_user)):
    return await handle_application(user["_id"], app_id, accept=False)

class BoostRequest(BaseModel):
    boost_type: str

@router.post("/treasury/boost")
async def activate_boost_route(req: BoostRequest, user: dict = Depends(get_current_user)):
    from app.services.family_service import activate_boost
    return await activate_boost(user["_id"], req.boost_type)

@router.get("/rivalries")
async def rivalries_route(user: dict = Depends(get_current_user)):
    from app.services.family_service import get_rivalries
    return await get_rivalries(user["_id"])

@router.post("/transfer_ownership/{target_user_id}")
async def transfer_ownership(target_user_id: str, user: dict = Depends(get_current_user)):
    from app.services.family_service import transfer_boss
    return await transfer_boss(user["_id"], target_user_id)

@router.post("/chat/{msg_id}/pin")
async def pin_chat_message(msg_id: str, user: dict = Depends(get_current_user)):
    from app.services.family_service import pin_message
    return await pin_message(user["_id"], msg_id)

@router.get("/achievements")
async def get_achievements_route(user: dict = Depends(get_current_user)):
    from app.services.family_service import get_achievements
    return await get_achievements(user["_id"])
