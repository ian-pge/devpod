cd /home/zed/dotfiles
out="$(nix build .#homeConfigurations.zed.activationPackage --no-link --print-out-paths)"
"$out/activate"
