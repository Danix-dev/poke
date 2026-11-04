#!/bin/bash
# Source this file from a custom R36S / ArkOS mkxp-z launcher.
# These are the video/runtime settings used by the tested R36S setup.

export SDL_VIDEODRIVER=kmsdrm
export SDL_VIDEO_DOUBLE_BUFFER=1

# Optional ArkOS controller database used by gptokeyb/SDL setups.
if [ -f /opt/inttools/gamecontrollerdb.txt ]; then
  export SDL_GAMECONTROLLERCONFIG_FILE=/opt/inttools/gamecontrollerdb.txt
fi
