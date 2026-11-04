#!/bin/bash
set -u

ENGINE_DIR="${1:-/roms/ports/mkxp}"
LOG="${2:-./r36s-mkxp-diagnostics.txt}"

{
  echo "=== R36S / ArkOS mkxp-z diagnostics ==="
  date 2>/dev/null || true
  echo

  echo "[System]"
  uname -a 2>/dev/null || true
  echo

  echo "[Engine directory]"
  echo "ENGINE_DIR=$ENGINE_DIR"
  ls -l "$ENGINE_DIR" 2>/dev/null || true
  echo

  echo "[mkxp-z]"
  if [ -e "$ENGINE_DIR/mkxp-z" ]; then
    file "$ENGINE_DIR/mkxp-z" 2>/dev/null || true
    ldd "$ENGINE_DIR/mkxp-z" 2>/dev/null || true
  else
    echo "MISSING: $ENGINE_DIR/mkxp-z"
  fi
  echo

  echo "[time64 libasound]"
  for f in "$ENGINE_DIR/libasound.so.2" "$ENGINE_DIR/libasound.so.2.0.0"; do
    if [ -e "$f" ]; then
      file "$f" 2>/dev/null || true
      ls -l "$f" 2>/dev/null || true
    else
      echo "MISSING: $f"
    fi
  done
  echo

  echo "[ALSA]"
  echo "ALSA_CONFIG_DIR=${ALSA_CONFIG_DIR:-<unset>}"
  echo "ALSA_CONFIG_PATH=${ALSA_CONFIG_PATH:-<unset>}"
  echo "ALSA_PLUGIN_DIR=${ALSA_PLUGIN_DIR:-<unset>}"
  echo "ALSOFT_DRIVERS=${ALSOFT_DRIVERS:-<unset>}"
  echo
  aplay -l 2>/dev/null || true
  echo
  aplay -L 2>/dev/null || true
  echo
  ls -l /dev/snd 2>/dev/null || true
  echo

  echo "[Controller/input devices]"
  ls -l /dev/input 2>/dev/null || true
  echo
  for dev in /sys/class/input/event*/device/name; do
    [ -f "$dev" ] || continue
    printf "%s: " "$dev"
    cat "$dev" 2>/dev/null || true
  done
  echo

  echo "[SDL/runtime variables]"
  echo "SDL_VIDEODRIVER=${SDL_VIDEODRIVER:-<unset>}"
  echo "SDL_VIDEO_DOUBLE_BUFFER=${SDL_VIDEO_DOUBLE_BUFFER:-<unset>}"
  echo "SDL_GAMECONTROLLERCONFIG=${SDL_GAMECONTROLLERCONFIG:-<unset>}"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-<unset>}"
  echo

  echo "[Quick checks]"
  [ -x "$ENGINE_DIR/mkxp-z" ] && echo "OK: mkxp-z executable" || echo "FAIL: mkxp-z missing/not executable"
  [ -e "$ENGINE_DIR/libasound.so.2" ] && echo "OK: local libasound.so.2 present" || echo "FAIL: local libasound.so.2 missing"
  [ -f /usr/share/alsa/alsa.conf ] && echo "OK: ArkOS ALSA config present" || echo "WARN: /usr/share/alsa/alsa.conf missing"
  [ -d /dev/snd ] && echo "OK: /dev/snd present" || echo "WARN: /dev/snd missing"
  [ -d /dev/input ] && echo "OK: /dev/input present" || echo "WARN: /dev/input missing"
} > "$LOG" 2>&1

echo "Diagnostics written to: $LOG"
