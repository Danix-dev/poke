#!/bin/bash
set -u

GAME_DIR="${1:-/roms/ports/mkxp}"
SCRIPTS_DIR="$GAME_DIR/Scripts"
TARGET="$SCRIPTS_DIR/TextEntry.rb"
BACKUP="$SCRIPTS_DIR/TextEntry.rb.r36s-original"
LOG="$GAME_DIR/textentry-r36s-restore.log"

{
    echo "=== Restore Rejuvenation TextEntry.rb ==="

    if [ ! -f "$BACKUP" ]; then
        echo "ERROR: backup not found: $BACKUP"
        exit 1
    fi

    cp -f "$BACKUP" "$TARGET"
    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-FIX.rb
    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-SIMPLE-GRID.rb
    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-*.rb
    sync
    echo "SUCCESS: restored $TARGET"
} > "$LOG" 2>&1

exit 0
