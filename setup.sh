#!/usr/bin/env bash
set -euo pipefail

CHEZ="$HOME/.local/bin/chezmoi"

if [[ ! -x $CHEZ ]]; then
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
   "$CHEZ" init https://github.com/ian-pge/chezmoi.git --apply
 fi
