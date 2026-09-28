{
  description = "Fuchsia development environment for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          fuchsiaBashrc = pkgs.writeText "fuchsia-bashrc" ''
            # Match ordinary interactive Bash behavior before adding Fuchsia's
            # helpers and programmable completions.
            if [[ -r "$HOME/.bashrc" ]]; then
              source "$HOME/.bashrc"
            fi
            source "$FUCHSIA_DIR/scripts/fx-env.sh"
          '';

          fuchsiaFhs = pkgs.buildFHSEnv {
            name = "fuchsia-dev";

            # Fuchsia supplies its own pinned compilers, build tools, language
            # runtimes, and SDK. These are only the host tools and libraries
            # expected by its scripts and downloaded Linux prebuilts.
            targetPkgs =
              p: with p; [
                bashInteractive
                bzip2
                cacert
                ccache
                coreutils
                curl
                diffutils
                file
                findutils
                gawk
                git
                gnugrep
                gnused
                gnutar
                gzip
                inotify-tools
                iproute2
                openssh
                procps
                rsync
                socat
                unzip
                util-linux
                which
                xz
                zip
                zstd

                # Libraries used by Fuchsia's downloaded host tools and FEMU.
                alsa-lib
                cups
                dbus
                expat
                fontconfig
                freetype
                libGL
                libGLU
                libbsd
                libdrm
                libpng
                libpulseaudio
                libxkbcommon
                libxkbfile
                nspr
                nss
                openssl
                stdenv.cc.cc.lib
                vulkan-loader
                wayland
                zlib

                libX11
                libXcomposite
                libXcursor
                libXdamage
                libXext
                libXfixes
                libXi
                libXinerama
                libXrandr
                libXrender
                libXtst
                libxcb
              ];

            runScript = "bash --rcfile ${fuchsiaBashrc}";

            profile = ''
              export SHELL=/bin/bash

              # Prefer an explicitly selected checkout. Otherwise, discover the
              # checkout containing the directory from which the shell was entered.
              if [[ -n "''${FUCHSIA_DIR:-}" ]]; then
                fuchsia_root="$FUCHSIA_DIR"
              else
                fuchsia_root="$PWD"
                while [[ "$fuchsia_root" != / && ! -e "$fuchsia_root/.jiri_manifest" ]]; do
                  fuchsia_root="$(dirname "$fuchsia_root")"
                done
              fi

              if [[ ! -e "$fuchsia_root/.jiri_manifest" ]]; then
                echo "fuchsia-dev: '$fuchsia_root' is not a Fuchsia checkout (missing .jiri_manifest)" >&2
                unset fuchsia_root
                exit 1
              fi

              # Keep the exported path valid after moving elsewhere.
              fuchsia_root="$(cd "$fuchsia_root" && pwd -P)"
              export FUCHSIA_DIR="$fuchsia_root"
              unset fuchsia_root

              # Configure symbolization and expose the same broad prebuilt tool
              # PATH as Fuchsia's .mise integration. Interactive helpers and
              # completions are loaded later by fuchsiaBashrc.
              export DEBUGINFOD_URLS="$(source "$FUCHSIA_DIR/tools/devshell/lib/vars.sh" && printf %s "$DEBUGINFOD_URLS")"
              source "$FUCHSIA_DIR/tools/devshell/lib/platform.sh"
              export PATH="$FUCHSIA_DIR/.jiri_root/bin:$PREBUILT_ALL_PATHS:$PREBUILT_TOOL_PATHS:$PATH"
            '';
          };
        in
        {
          default = fuchsiaFhs.env;
        }
      );
    };
}
