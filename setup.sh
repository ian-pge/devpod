#!/usr/bin/env bash
set -euo pipefail

# Make sure nix is found even very early in container setup
export PATH="/home/zed/.nix-profile/bin:/nix-profile/bin:${PATH}"

# Make nix behave consistently
export NIX_REMOTE="${NIX_REMOTE:-daemon}"
export NIX_SSL_CERT_FILE="${NIX_SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}"
export NIX_CONFIG="${NIX_CONFIG:-experimental-features = nix-command flakes
accept-flake-config = true}"

cd "${HOME}/dotfiles"

out="$(nix build ".#homeConfigurations.zed.activationPackage" --no-link --print-out-paths)"
"$out/activate"
