#!/bin/bash

# Change only GAME_DIR for another compatible mkxp-z / RPG Maker XP game.
GAME_DIR="/roms/ports/Your Game"
RUNNER="/roms/ports/mkxp/run-mkxp-time64.sh"

exec "$RUNNER" "$GAME_DIR"
