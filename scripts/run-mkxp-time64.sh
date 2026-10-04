#!/bin/bash

GAME_DIR="${1:-}"
ENGINE_DIR="${2:-/roms/ports/mkxp}"

if [ -z "$GAME_DIR" ]; then
    echo "Usage: $0 /path/to/game [engine_dir]"
    exit 1
fi

if [ ! -d "$GAME_DIR" ]; then
    echo "Game directory not found: $GAME_DIR"
    exit 1
fi

if [ ! -x "$ENGINE_DIR/mkxp-z" ]; then
    echo "mkxp-z not found or not executable: $ENGINE_DIR/mkxp-z"
    exit 1
fi

if [ ! -f "$ENGINE_DIR/libasound.so.2" ]; then
    echo "Missing time64 ALSA library: $ENGINE_DIR/libasound.so.2"
    exit 1
fi

export SDL_VIDEODRIVER=kmsdrm
export SDL_VIDEO_DOUBLE_BUFFER=1

export LD_LIBRARY_PATH="$ENGINE_DIR:${LD_LIBRARY_PATH:-}"

export ALSA_CONFIG_DIR="/usr/share/alsa"
export ALSA_CONFIG_PATH="/usr/share/alsa/alsa.conf"

if [ -d "/usr/lib/arm-linux-gnueabihf/alsa-lib" ]; then
    export ALSA_PLUGIN_DIR="/usr/lib/arm-linux-gnueabihf/alsa-lib"
elif [ -d "/lib/arm-linux-gnueabihf/alsa-lib" ]; then
    export ALSA_PLUGIN_DIR="/lib/arm-linux-gnueabihf/alsa-lib"
fi

export ALSOFT_DRIVERS=alsa

cd "$GAME_DIR" || exit 1
exec "$ENGINE_DIR/mkxp-z"
