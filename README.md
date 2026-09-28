# Nix dev shell for Fuchsia development

The [Fuchsia](https://fuchsia.dev) development environment assumes a
conventional Linux system, which does not work directly on NixOS. This flake
provides an FHS-compatible shell containing the host tools and libraries that
Fuchsia's scripts and Linux prebuilts expect.

Fuchsia still supplies its own pinned compilers, build tools, language
runtimes, and SDK.

## Usage

Select a Fuchsia checkout and enter the shell:

```bash
export FUCHSIA_DIR="$HOME/dev/fuchsia"
nix develop ~/dev/fuchsia-nix
```

`FUCHSIA_DIR` is validated and normalized to an absolute path, so you can enter
the shell from this repository and then move anywhere:

```bash
cd "$FUCHSIA_DIR"
fx status
```

Alternatively, when starting from inside a Fuchsia checkout, the shell
discovers its root automatically:

```bash
cd ~/dev/fuchsia/src
nix develop ~/dev/fuchsia-nix
```

The selected directory must contain `.jiri_manifest`.
