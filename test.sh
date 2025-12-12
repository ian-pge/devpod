#!/usr/bin/env bash
#
# A robust script to ensure Nix is installed, Home Manager configuration is activated,
# and zsh is set as the default shell.

set -euo pipefail

# Basic logging function
log() {
  echo -e "[INFO] $*"
}

# Error handler to display a message if any command fails
trap 'echo "[ERROR] Script failed at line $LINENO. Exiting." >&2' ERR

# 1. Source Nix if it’s already installed.
if [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  log "Nix installed and sourced."
fi

# 2. Check if Nix is available; if not, install it.
if ! command -v nix &>/dev/null; then
  log "Nix not found in PATH. Installing Nix..."

  # check if docker has leaked in some nix stuff from the host
  if [[ -d "/nix" ]]; then
    sudo mv /nix /nix_docker
    log "Nix stuff has leaked from the host"
  fi

  # Non-interactive installation of Nix (single-user)
  curl -L https://nixos.org/nix/install | bash -s -- --no-daemon
  # Source Nix again (the install just happened)
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"

  # copy to the nix store
  if [[ -d "/nix_docker" ]]; then
    sudo cp -a /nix_docker/store/* /nix/store/
    log "copy pkgs to nix store"
  fi

else
  log "Nix is already installed."
fi

# 3. Ensure Nix profile is sourced if NIX_PATH is not set (extra safeguard).
if [[ -z "${NIX_PATH:-}" ]]; then
  log "Sourcing Nix profile..."
  # shellcheck source=/dev/null
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# 4. Build and activate the Home Manager configuration if needed.
if [[ ! -L "${HOME}/result" ]]; then
  log "Building Home Manager flake..."
  nix build .#homeConfigurations.zed.activationPackage \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    --out-link "${HOME}/result"
  log "Activating Home Manager configuration..."
  "${HOME}/result/activate"
else
  log "Home Manager configuration already activated."
fi

# 5. Make sure zsh from Nix is linked to /bin/zsh (for setting login shell).
FISH_LINK_TARGET="${HOME}/.nix-profile/bin/fish"
if [[ ! -f "/bin/fish" ]] || [[ "$(readlink /bin/fish 2>/dev/null || true)" != "$FISH_LINK_TARGET" ]]; then
  log "Linking Nix fish to /bin/fish..."
  sudo ln -sf "$FISH_LINK_TARGET" /bin/fish
fi

# 6. Change default shell to zsh if not already done.
CURRENT_SHELL="$(getent passwd "$(whoami)" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" != "/bin/fish" ]]; then
  log "Changing default shell to fish..."
  sudo usermod -s /bin/fish "$(whoami)"
fi

log "Setup complete!"
