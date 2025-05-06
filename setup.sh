#!/usr/bin/env bash
set -euo pipefail

CHEZ="$HOME/.local/bin/chezmoi"

if [[ ! -x $CHEZ ]]; then
   echo "Installing chezmoi..."
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
   echo "Apply chezmoi config..."
   "$CHEZ" init https://github.com/ian-pge/chezmoi.git --apply
else
   echo "Update chezmoi config..."
   "$CHEZ" update
fi
