# Additional R36S / ArkOS fixes and utilities

This directory contains optional helpers kept separate from the main mkxp-z audio and Rejuvenation text-entry fixes.

## Compatibility

The generic runtime, installer, diagnostics helper, and launchers are compatible with compatible Linux/mkxp-z builds of:

- Pokemon Reborn
- Pokemon Rejuvenation
- Pokemon Desolation

These games share the same general RPG Maker XP / Pokemon Essentials ecosystem, but individual game versions can still contain game-specific Ruby or Windows-only code.

The `fix-rejuvenation-text-entry.sh` patch in the main repository is different: its in-place `Scripts/TextEntry.rb` modification was physically verified on Pokemon Rejuvenation and should not be blindly applied to Reborn or Desolation unless their corresponding code is verified first.

## Files

### `install-r36s-mkxp.sh`

Installs the reusable R36S mkxp-z runtime into:

```text
/roms/ports/mkxp/
```

It installs:

- `mkxp-z`
- `libasound.so.2`
- `libasound.so.2.0.0`
- `run-mkxp-time64.sh`

Pre-existing runtime files are backed up to:

```text
/roms/ports/mkxp/backup-before-r36s-install/
```

Usage:

```bash
chmod +x install-r36s-mkxp.sh
./install-r36s-mkxp.sh
```

If the extracted release is elsewhere:

```bash
./install-r36s-mkxp.sh "/path/to/extracted/release"
```

## `diagnose-r36s.sh`

Collects useful information for debugging:

- system/CPU architecture;
- mkxp-z architecture and dynamic libraries;
- local time64 libasound files;
- ALSA devices/configuration;
- controller/input devices;
- SDL/runtime environment variables;
- quick pass/fail checks.

Usage:

```bash
chmod +x diagnose-r36s.sh
./diagnose-r36s.sh
```

The default output is:

```text
r36s-mkxp-diagnostics.txt
```

That log is useful when asking for help because it collects the main runtime, audio, controller and SDL information in one place.

## Ready-made launchers

The `launchers/` directory contains:

- `pokemon-reborn.sh`
- `pokemon-rejuvenation.sh`
- `pokemon-desolation.sh`

They all use:

```text
/roms/ports/mkxp/run-mkxp-time64.sh
```

and only differ in the default game directory.

If the game folder has a different name, edit `GAME_DIR` in the corresponding launcher or override it as an environment variable.

Example:

```bash
GAME_DIR="/roms/ports/Reborn" ./pokemon-reborn.sh
```

## Scope

These helpers intentionally remain separate from the main release/build workflow. This keeps the core audio/time64 fix reproducible while making optional installation, launch and troubleshooting helpers available to users who need them.
