# R36S / ArkOS mkxp-z Audio + Rejuvenation Text Entry Fix

A practical fix for **RPG Maker XP / mkxp-z games on R36S / ArkOS** that start correctly but have no audio or fail with:

```text
Could not detect an available audio device.
```

This repository contains:

- a working **ARM32 mkxp-z build** for R36S;
- a custom **ARM32 time64 alsa-lib**;
- reusable launch scripts;
- the GitHub Actions build workflow used to reproduce the binaries;
- a **verified Pokémon Rejuvenation controller text-entry fix** for handhelds without a physical keyboard;
- technical notes explaining the root cause.

## Confirmed working

Tested on an R36S running ArkOS with the Rockchip RK817 codec.

The final working setup uses:

```text
mkxp-z (ARM 32-bit)
        |
        v
OpenAL Soft
        |
        v
custom ARM32 time64 libasound.so.2
        |
        v
ArkOS ALSA configuration
        |
        v
rockchip,rk817-codec
```

The crucial environment variables are:

```bash
export ALSA_CONFIG_DIR=/usr/share/alsa
export ALSA_CONFIG_PATH=/usr/share/alsa/alsa.conf
export ALSOFT_DRIVERS=alsa
```

The local time64 ALSA library must be placed next to `mkxp-z`, and the launcher must include that directory in `LD_LIBRARY_PATH`.

## Why the normal ARM32 ALSA path fails

The R36S/ArkOS system is 64-bit, but the original mkxp-z port is ARM32.

During debugging:

- native `aplay` was confirmed to be **AArch64 / 64-bit**;
- `aplay -N -D default` successfully opened `/dev/snd/pcmC0D0p`;
- the ARM32 mkxp-z process successfully opened the same PCM device;
- the ARM32 path then failed on the ALSA PCM synchronization ioctl with `ENOTTY`;
- a custom ARM32 alsa-lib built with the time64 ABI was used to avoid the broken compat path.

The custom library is compiled with:

```text
-D_TIME_BITS=64
-D_FILE_OFFSET_BITS=64
```

A second issue was also discovered: the cross-built libasound retained its build-time ALSA configuration prefix. The launcher therefore explicitly sets:

```bash
ALSA_CONFIG_DIR=/usr/share/alsa
ALSA_CONFIG_PATH=/usr/share/alsa/alsa.conf
```

Without `ALSA_CONFIG_DIR`, libasound may try to load files from a path such as:

```text
/root/mkxp-z/linux/build-armv7old/share/alsa/
```

and fail with `Unknown PCM default` or `Unknown PCM cards.pcm.default`.

## Installation

Download the latest release from the repository's **Releases** section.

You need these files in:

```text
/roms/ports/mkxp/
```

Final layout:

```text
/roms/ports/mkxp/
├── mkxp-z
├── libasound.so.2
├── libasound.so.2.0.0
└── run-mkxp-time64.sh
```

Back up your existing `mkxp-z` before replacing it.

Then make the binaries/scripts executable if necessary:

```bash
chmod +x /roms/ports/mkxp/mkxp-z
chmod +x /roms/ports/mkxp/run-mkxp-time64.sh
```

## Using the generic launcher

For each compatible game, create a small script inside `/roms/ports/`.

Example:

```bash
#!/bin/bash

GAME_DIR="/roms/ports/Your Game"
RUNNER="/roms/ports/mkxp/run-mkxp-time64.sh"

exec "$RUNNER" "$GAME_DIR"
```

Only change `GAME_DIR`.

The generic runner automatically configures:

- KMSDRM video;
- SDL double buffering;
- the local ARM32 time64 libasound;
- ArkOS ALSA configuration paths;
- OpenAL -> ALSA;
- ARM32 ALSA plugins when available.

## Controller text entry on R36S — verified on Pokémon Rejuvenation

Pokémon Rejuvenation already contains controller-driven character-grid text-entry scenes. The issue on R36S is that the game can route name/text entry to its physical-keyboard path, which depends on SDL text input and cannot receive arbitrary characters from the handheld controls.

In the tested Rejuvenation build, `Scripts/TextEntry.rb` makes this choice through `$Settings.useKeyboard?`. The working R36S fix patches the existing file **in place** so its two routing points choose the game's own controller character grid:

- `Kernel.pbMessageFreeText`: use the non-keyboard branch;
- `pbEnterText`: use the non-keyboard / character-grid branch.

This was physically verified on an R36S: the on-screen character grid appeared, a player name was entered using the handheld controls, and Rejuvenation accepted it.

Run:

```bash
/roms/ports/mkxp/fix-rejuvenation-text-entry.sh
```

The helper defaults to `/roms/ports/mkxp`. If the game is elsewhere, pass its directory:

```bash
/roms/ports/mkxp/fix-rejuvenation-text-entry.sh "/roms/ports/Pokemon Rejuvenation"
```

The helper:

1. backs up `Scripts/TextEntry.rb` as `TextEntry.rb.r36s-original`;
2. removes obsolete experimental `TextEntry-R36S-*.rb` copies;
3. patches only the two routing decisions;
4. validates both changes;
5. restores the backup automatically if the expected Rejuvenation code is not found.

To undo the fix:

```bash
/roms/ports/mkxp/restore-rejuvenation-text-entry.sh
```

> [!IMPORTANT]
> Do **not** place a second complete `TextEntry.rb` implementation in Rejuvenation's `Scripts/` directory. Duplicate loose Ruby scripts can redefine the same classes/methods and cause crashes.

The old generic `r36s-controller-text-entry.rb` injection has been removed. This fix is confirmed for the tested Rejuvenation build; other Pokémon Essentials fangames may use different text-entry code.

## Game-specific Ruby fixes

This project fixes the **engine/audio layer**.

Some Pokémon fangames or other RPG Maker XP games may still need game-specific Ruby compatibility patches, for example for:

- old `Gem::Version` usage;
- updater/network code;
- Discord Rich Presence DLL/SO integrations;
- Windows-only APIs;
- save conversion logic;
- RTP checks.

Those are separate from the ALSA fix and may differ between games.

## Low latency

The generic runner keeps:

```bash
export SDL_VIDEO_DOUBLE_BUFFER=1
```

which was useful on the tested R36S setup for reducing input/display latency.

## Building from source

The reproducible workflow is in:

```text
.github/workflows/build-r36s-system-alsa.yml
```

The workflow:

1. prepares the ARMv7 cross toolchain;
2. applies the original R36S mkxp-z patches;
3. pins mkxp-z to a compatible pre-build-system-overhaul revision;
4. builds alsa-lib for ARM32 with the time64 ABI;
5. builds OpenAL Soft with ALSA linked directly;
6. builds all required dependencies;
7. builds and packages mkxp-z;
8. verifies that the final engine depends on `libasound.so.2`;
9. publishes downloadable artifacts.

## Troubleshooting

### `Could not detect an available audio device`

Check that:

```text
/roms/ports/mkxp/libasound.so.2
/roms/ports/mkxp/libasound.so.2.0.0
```

exist and that your launcher includes:

```bash
export LD_LIBRARY_PATH="/roms/ports/mkxp:${LD_LIBRARY_PATH:-}"
export ALSA_CONFIG_DIR="/usr/share/alsa"
export ALSA_CONFIG_PATH="/usr/share/alsa/alsa.conf"
export ALSOFT_DRIVERS=alsa
```

### `Unknown PCM default`

The time64 libasound is being loaded, but the ArkOS ALSA config tree is not.

Set:

```bash
export ALSA_CONFIG_DIR="/usr/share/alsa"
export ALSA_CONFIG_PATH="/usr/share/alsa/alsa.conf"
```

### Test the R36S audio system directly

```bash
aplay -N -D default /usr/share/sounds/alsa/Front_Center.wav
```

If you hear “Front Center”, the underlying RK817/ALSA output is working.

## Credits

This solution builds on the existing R36S mkxp-z port and the upstream projects:

- mkxp-z
- OpenAL Soft
- ALSA / alsa-lib
- ArkOS
- the R36S community

The repository exists mainly to make the verified R36S ARM32/ArkOS audio fix and the tested Rejuvenation controller text-entry fix reproducible and easier for other users to apply.

## Disclaimer

This is a community compatibility project. It is not affiliated with ArkOS, RPG Maker, Pokémon, Nintendo, mkxp-z, or the R36S manufacturers.

Always keep backups of your existing game and engine files.
