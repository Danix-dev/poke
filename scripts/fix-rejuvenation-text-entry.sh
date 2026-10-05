#!/bin/bash
set -u

GAME_DIR="${1:-/roms/ports/mkxp}"
SCRIPTS_DIR="$GAME_DIR/Scripts"
TARGET="$SCRIPTS_DIR/TextEntry.rb"
BACKUP="$SCRIPTS_DIR/TextEntry.rb.r36s-original"
LOG="$GAME_DIR/textentry-r36s-fix.log"

{
    echo "=== R36S / ArkOS Rejuvenation text-entry fix ==="
    echo "game_dir=$GAME_DIR"
    echo "target=$TARGET"
    echo

    if [ ! -f "$TARGET" ]; then
        echo "ERROR: TextEntry.rb not found."
        echo "Expected: $TARGET"
        exit 1
    fi

    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-FIX.rb
    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-SIMPLE-GRID.rb
    rm -f "$SCRIPTS_DIR"/TextEntry-R36S-*.rb

    if [ ! -f "$BACKUP" ]; then
        cp -p "$TARGET" "$BACKUP"
        echo "Backup created: $BACKUP"
    else
        echo "Backup already exists: $BACKUP"
    fi

    sed -i '/def Kernel\.pbMessageFreeText/,/^end$/ s/unless \$Settings\.useKeyboard?/if true/' "$TARGET"
    sed -i '/def pbEnterText(helptext/,/^end$/ s/if \$Settings\.useKeyboard?/if false/' "$TARGET"

    if grep -A8 "def Kernel.pbMessageFreeText" "$TARGET" | grep -q "if true" && \
       grep -A12 "def pbEnterText(helptext" "$TARGET" | grep -q "if false"; then
        echo "SUCCESS: controller character-grid text entry enabled."
    else
        echo "ERROR: expected Rejuvenation routing points were not found."
        cp -f "$BACKUP" "$TARGET"
        exit 2
    fi

    sync
} > "$LOG" 2>&1

exit 0
