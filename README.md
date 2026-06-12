# xmos-dfu

A Nix flake packaging [`jdslabs/xmos_dfu`](https://github.com/jdslabs/xmos_dfu) —
JDS Labs' CLI DFU utility for flashing XMOS-based USB DAC firmware.

It pulls upstream at a pinned commit via `fetchFromGitHub` and applies a
one-line patch adding the **iFi XU216** product ID (`0x3008`) to the recognized
device list, so the tool also works with iFi DACs built on the XMOS XU216
(vendor ID `0x20b1` is already handled upstream).

## Usage

Run directly:

```sh
nix run github:rivavolt/xmos-dfu
```

Build:

```sh
nix build github:rivavolt/xmos-dfu
./result/bin/xmosdfu
```

The package attribute is `packages.<system>.default` (also `.xmos-dfu`), built
for `x86_64-linux` and `aarch64-linux`.

## License

Upstream `xmos_dfu` is MIT-licensed; see the upstream repository.
