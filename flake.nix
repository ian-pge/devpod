{
  description = "Home Manager config for Ubuntu devcontainer (using host nix-daemon)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations.zed = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ({pkgs, ...}: {
          home.username = "zed";
          home.homeDirectory = "/home/zed";
          home.stateVersion = "24.11";

          # Handy: provides `home-manager` command inside the environment
          programs.home-manager.enable = true;

          home.packages = [
            pkgs."net-tools" # current top-level attr is net-tools
            pkgs.fastfetch # maintained neofetch-like alternative
          ];

          programs.fish = {
            enable = true;

            interactiveShellInit = ''
              set -g fish_greeting
              fish_vi_key_bindings

              # newline after each command (valid fish syntax)
              function __newline_postexec --on-event fish_postexec
                echo
              end

              function _aichat_fish
                set -l text (commandline)
                if test -n "$text"
                  commandline -r ""
                  printf '\r\e[2C\e[K'
                  set -l out (aichat -e -- "$text")
                  commandline -r "$out"
                  commandline -f repaint
                end
              end
              bind \ee _aichat_fish
            '';

            plugins = [
              {
                name = "bass";
                src = pkgs.fishPlugins.bass.src;
              }
            ];
          };

          programs.neovim = {
            enable = true;
            extraLuaConfig = ''
              vim.opt.number = true
              vim.opt.shortmess:append("I")
            '';
          };

          programs.fzf = {
            enable = true;
            enableFishIntegration = true;
          };

          programs.bat.enable = true;

          # ── Starship ──────────────────────────────────────────────────────────────────
          programs.starship = {
            enable = true;
            enableFishIntegration = true;
            enableTransience = true;

            settings = {
              # ─ Global options ─────────────────────────────────────────────────────────
              right_format = "$cmd_duration"; # right-prompt → 27 ms

              # Palette (same hex codes you used in Oh-My-Posh) ─────────────────────────
              palette = "catppuccin";

              palettes.catppuccin = {
                blue = "#8AADF4";
                green = "#a6da95";
                lavender = "#B7BDF8";
                mauve = "#c6a0f6";
                os = "#ACB0BE";
                peach = "#F5A97F";
                pink = "#F5BDE6";
                sapphire = "#7dc4e4";
                yellow = "#eed49f";
                sky = "#91d7e3";
                flamingo = "#f0c6c6";
                rosewater = "#f4dbd6";
                maroon = "#ee99a0";
                teal = "#8bd5ca";
              };

              # ─ What gets printed on the left prompt line ─────────────────────────────
              format = ''
                $os $username@$hostname $directory $git_branch$line_break$character
              '';

              add_newline = false;

              # 1 • Current time (18:49) -------------------------------------------------
              time = {
                disabled = false;
                time_format = "%H:%M";
                style = "fg:yellow";
                format = "[$time]($style) "; # trailing space ␠
              };

              # 2 • OS icon (snow-flake Nix) --------------------------------------------
              os = {
                disabled = false;
                style = "fg:sky";
                format = "[$symbol]($style)";
                symbols = {
                  NixOS = "";
                  Ubuntu = "";
                  Arch = "";
                  Fedora = "";
                  Debian = "";
                };
              };

              # 3 • user@host ------------------------------------------------------------
              username = {
                show_always = true;
                style_user = "fg:pink";
                style_root = "fg:red";
                format = "[$user]($style)";
              };
              hostname = {
                ssh_only = false;
                style = "fg:mauve";
                format = "[$hostname]($style)"; # trailing space
              };

              # 4 • Path (“~/workspace/…”) ----------------------------------------------
              directory = {
                truncation_length = 0;
                truncate_to_repo = false;
                home_symbol = "~";
                style = "fg:flamingo";
                read_only = " ";
                read_only_style = "fg:flamingo";
                format = "[$read_only]($read_only_style)[$path]($style)";
                repo_root_format = "[$read_only]($read_only_style)[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($repo_root_style)";
                before_repo_root_style = "fg:flamingo";
                repo_root_style = "fg:teal";
              };

              # 5 • Git HEAD -------------------------------------------------------------
              git_branch = {
                symbol = " ";
                style = "fg:teal";
                format = "[$symbol$branch]($style) ";
              };

              container = {
                symbol = " ";
                style = "fg:maroon";
                format = "[$symbol$container]($style) ";
              };

              # ── second line: prompt symbol ❯  ─────────────────────────────────────────
              character = {
                success_symbol = "[❯](green)";
                error_symbol = "[❯](fg:red)";
                vimcmd_symbol = "[❮](fg:peach)";
                vimcmd_visual_symbol = "[❮](fg:mauve)";
                vimcmd_replace_symbol = "[❮](fg:sky)";
                vimcmd_replace_one_symbol = "[❮](fg:pink)";
              };

              # ── right prompt: elapsed time (27 ms) ───────────────────────────────────
              cmd_duration = {
                min_time = 0; # always display
                show_milliseconds = true;
                style = "fg:peach";
                format = "[$duration]($style)";
              };
            };
          };
        })
      ];
    };
  };
}
