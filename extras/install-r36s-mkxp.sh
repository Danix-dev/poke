#!/bin/bash
set -u

SOURCE_DIR="${1:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
TARGET_DIR="${2:-/roms/ports/mkxp}"
BACKUP_DIR="$TARGET_DIR/backup-before-r36s-install"

required=(
  mkxp-z
  libasound.so.2
  libasound.so.2.0.0
  run-mkxp-time64.sh
)

for file in "${required[@]}"; do
  if [ ! -e "$SOURCE_DIR/$file" ]; then
    echo "ERROR: missing $SOURCE_DIR/$file"
    echo "Run this installer from the extracted R36S mkxp-z release folder"
    echo "or pass that folder as the first argument."
    exit 1
  fi
done

mkdir -p "$TARGET_DIR"
mkdir -p "$BACKUP_DIR"

for file in "${required[@]}"; do
  if [ -e "$TARGET_DIR/$file" ] && [ ! -e "$BACKUP_DIR/$file" ]; then
    cp -a "$TARGET_DIR/$file" "$BACKUP_DIR/$file"
  fi
done

cp -f "$SOURCE_DIR/mkxp-z" "$TARGET_DIR/mkxp-z"
cp -Lf "$SOURCE_DIR/libasound.so.2" "$TARGET_DIR/libasound.so.2"
cp -f "$SOURCE_DIR/libasound.so.2.0.0" "$TARGET_DIR/libasound.so.2.0.0"
cp -f "$SOURCE_DIR/run-mkxp-time64.sh" "$TARGET_DIR/run-mkxp-time64.sh"

chmod +x "$TARGET_DIR/mkxp-z" "$TARGET_DIR/run-mkxp-time64.sh"
sync

echo "Installed R36S mkxp-z compatibility runtime to: $TARGET_DIR"
echo "Backup of pre-existing runtime files: $BACKUP_DIR"
echo
echo "This runtime/installer is game-agnostic and can be used with compatible"
echo "mkxp-z/RPG Maker XP builds such as Pokemon Reborn, Pokemon Rejuvenation"
echo "and Pokemon Desolation. Game-specific Ruby fixes may still differ."
