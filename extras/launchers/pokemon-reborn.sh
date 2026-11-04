#!/bin/bash

GAME_DIR="${GAME_DIR:-/roms/ports/Pokemon Reborn}"
RUNNER="${RUNNER:-/roms/ports/mkxp/run-mkxp-time64.sh}"

if [ ! -d "$GAME_DIR" ]; then
  echo "Pokemon Reborn directory not found: $GAME_DIR"
  echo "Edit GAME_DIR in this launcher if your folder has a different name."
  exit 1
fi

exec "$RUNNER" "$GAME_DIR"
