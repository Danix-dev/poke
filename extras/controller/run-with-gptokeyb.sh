#!/bin/bash
set -u

GAME_DIR="${1:-}"
ENGINE_DIR="${2:-/roms/ports/mkxp}"
CONFIG="${3:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/pokemon-essentials.gptk}"
GPTOKEYB="${GPTOKEYB:-/opt/inttools/gptokeyb}"
LOG="${GPTOKEYB_LOG:-$GAME_DIR/gptokeyb-log.txt}"

if [ -z "$GAME_DIR" ]; then
  echo "Usage: $0 /path/to/game [engine_dir] [config.gptk]"
  exit 1
fi

if [ ! -x "$GPTOKEYB" ]; then
  echo "ERROR: gptokeyb not found or not executable: $GPTOKEYB"
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: gptokeyb config not found: $CONFIG"
  exit 1
fi

if [ ! -x "$ENGINE_DIR/run-mkxp-time64.sh" ]; then
  echo "ERROR: R36S mkxp runner not found: $ENGINE_DIR/run-mkxp-time64.sh"
  exit 1
fi

sudo chmod 666 /dev/uinput 2>/dev/null || true

if [ -f /opt/inttools/gamecontrollerdb.txt ]; then
  export SDL_GAMECONTROLLERCONFIG_FILE=/opt/inttools/gamecontrollerdb.txt
fi

"$GPTOKEYB" -c "$CONFIG" > "$LOG" 2>&1 &
GPTOKEYB_PID=$!

cleanup() {
  kill "$GPTOKEYB_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

"$ENGINE_DIR/run-mkxp-time64.sh" "$GAME_DIR"
STATUS=$?

exit "$STATUS"
