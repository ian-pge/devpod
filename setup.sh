#!/usr/bin/env bash
set -euo pipefail

cd "${HOME}/dotfiles"

out="$(nix build ".#homeConfigurations.zed.activationPackage" --no-link --print-out-paths)"
"$out/activate"

fastfetch
