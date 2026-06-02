import os
import time
from agora_token_builder import RtcTokenBuilder

AGORA_APP_ID = os.getenv("AGORA_APP_ID", "")
AGORA_APP_CERTIFICATE = os.getenv("AGORA_APP_CERTIFICATE", "")

def generate_rtc_token(channel_name: str, uid: int = 0, role: int = 1, expire_time_in_seconds: int = 3600) -> str:
    """
    Generate an Agora RTC token.
    role: 1 for publisher (broadcaster), 2 for subscriber (audience)
    """
    if not AGORA_APP_ID or not AGORA_APP_CERTIFICATE:
        raise ValueError("Agora APP_ID or APP_CERTIFICATE is missing in environment variables.")

    current_timestamp = int(time.time())
    privilege_expired_ts = current_timestamp + expire_time_in_seconds

    # We use buildTokenWithUid. 
    # For user string IDs in Flutter, we typically use buildTokenWithUserAccount,
    # but buildTokenWithUid with uid=0 allows anyone to join with this token if we want flexible testing,
    # OR we hash the string user_id into an int. Let's use string user account to be safe.
    
    # Actually, RtcTokenBuilder provides buildTokenWithUserAccount
    return RtcTokenBuilder.buildTokenWithUid(
        AGORA_APP_ID, 
        AGORA_APP_CERTIFICATE, 
        channel_name, 
        uid, 
        role, 
        privilege_expired_ts
    )

def generate_rtc_token_with_account(channel_name: str, account: str, role: int = 1, expire_time_in_seconds: int = 3600) -> str:
    if not AGORA_APP_ID or not AGORA_APP_CERTIFICATE:
        # Fallback for testing environments where the Agora App has "No Certificate" enabled
        return ""

    current_timestamp = int(time.time())
    privilege_expired_ts = current_timestamp + expire_time_in_seconds

    return RtcTokenBuilder.buildTokenWithUserAccount(
        AGORA_APP_ID, 
        AGORA_APP_CERTIFICATE, 
        channel_name, 
        account, 
        role, 
        privilege_expired_ts
    )
