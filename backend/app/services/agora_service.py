import os
import time
from agora_token_builder import RtcTokenBuilder

AGORA_APP_ID = os.getenv("AGORA_APP_ID", "")
AGORA_APP_CERTIFICATE = os.getenv("AGORA_APP_CERTIFICATE", "")

def generate_rtc_token_with_account(channel_name: str, account: str, role: int = 1, expire_time_in_seconds: int = 3600) -> str:
    """
    Generate an Agora RTC token using User Account (String).
    """
    if not AGORA_APP_ID or not AGORA_APP_CERTIFICATE:
        raise ValueError("Agora APP_ID or APP_CERTIFICATE is missing in environment variables.")

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
