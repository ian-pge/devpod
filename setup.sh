#!/usr/bin/env bash
set -euo pipefail

cd "${HOME}/dotfiles"

out="$(nix build ".#homeConfigurations.zed.activationPackage" --no-link --print-out-paths)"
"$out/activate"

# 6. Change default shell to fish
CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" != "/bin/fish" ]]; then
  log "Changing default shell to fish..."
  sudo usermod -s /bin/fish "$(whoami)"
fi
