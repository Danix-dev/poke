# Technical diagnosis

This document records the debugging path that led to the working R36S / ArkOS audio fix.

## Symptoms

mkxp-z started the RPG Maker XP game, but audio initialization failed with:

```text
Could not detect an available audio device.
```

OpenAL Soft reported:

```text
Supported backends: alsa, null, wave
Initialized backend "alsa"
Opening device "default"
Failed to open playback device: Could not open ALSA device "default"
```

## Native ALSA was healthy

ArkOS exposed the RK817 codec and standard ALSA PCMs. A direct test worked:

```bash
aplay -N -D default /usr/share/sounds/alsa/Front_Center.wav
```

The test produced audible output.

## 64-bit vs 32-bit difference

The ArkOS `aplay` executable was AArch64 and loaded:

```text
/lib/aarch64-linux-gnu/libasound.so.2
```

The R36S mkxp-z port was ARM32 and loaded the armhf ALSA library.

A syscall trace showed that both processes could open:

```text
/dev/snd/pcmC0D0p
```

The native AArch64 path successfully used `SNDRV_PCM_IOCTL_SYNC_PTR`.

The ARM32 path reached the PCM device but its compatible ioctl path failed with `ENOTTY`.

## Fix

alsa-lib 1.2.11 is cross-built for ARM32 with:

```text
-D_TIME_BITS=64
-D_FILE_OFFSET_BITS=64
```

The resulting `libasound.so.2` is kept next to `mkxp-z` and selected through `LD_LIBRARY_PATH`.

## Cross-build configuration prefix

The custom alsa-lib initially tried to load:

```text
/root/mkxp-z/linux/build-armv7old/share/alsa/alsa.conf
```

Setting only `ALSA_CONFIG_PATH` fixed the main file but nested includes still used the build prefix.

The final launcher therefore sets both:

```bash
export ALSA_CONFIG_DIR="/usr/share/alsa"
export ALSA_CONFIG_PATH="/usr/share/alsa/alsa.conf"
```

This makes the custom ARM32 library use the actual ArkOS ALSA configuration tree.

## OpenAL

OpenAL Soft is built with ALSA linked directly rather than loaded at runtime:

```text
ALSOFT_DLOPEN=OFF
ALSOFT_BACKEND_ALSA=ON
ALSOFT_REQUIRE_ALSA=ON
```

The launcher also sets:

```bash
export ALSOFT_DRIVERS=alsa
```

There is intentionally no automatic `null` fallback in the final runner, because a null backend makes the game appear to work while silently disabling audio.
