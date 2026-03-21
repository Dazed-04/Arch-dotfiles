# ArchDotfiles

> Personal configuration files for my Arch Linux setup. Shared under GPL for anyone who finds it useful.

---

## Screenshot

<!-- Add a screenshot of your setup here -->

---

## Contents

| Config      | Description                                                                 |
| ----------- | --------------------------------------------------------------------------- |
| `hyprland`  | Wayland compositor — keybinds, animations, workspace rules, scroller layout |
| `kitty`     | Terminal emulator                                                           |
| `nvim`      | Neovim editor config                                                        |
| `yazi`      | Terminal file manager                                                       |
| `rmpc`      | MPD TUI client — custom layout, theme, lyrics, cava visualizer              |
| `mpd`       | Music Player Daemon                                                         |
| `mpv`       | Media player                                                                |
| `spicetify` | Spotify client theming                                                      |
| `btop`      | Resource monitor                                                            |
| `fastfetch` | System info fetch                                                           |
| `matugen`   | Material You color generation                                               |
| `mpDris`    | MPRIS bridge for MPD                                                        |
| `ohmyposh`  | Shell prompt theme                                                          |
| `jerry`     | Anime/media CLI tool                                                        |
| `.zshrc`    | Zsh shell config                                                            |

---

## Installation

These are managed via manual symlinks. There is no automated install script — clone the repo and symlink what you need.

```bash
git clone https://github.com/Dazed-04/Arch-dotfiles.git ~/.dotfiles
```

Then symlink individual configs, for example:

```bash
ln -s ~/.dotfiles/configs/hyprland ~/.config/hypr
ln -s ~/.dotfiles/configs/kitty ~/.config/kitty
ln -s ~/.dotfiles/configs/nvim ~/.config/nvim
# etc.
```

---

## Dependencies

A non-exhaustive list of packages needed for everything to work:

```
hyprland hyprscroller
kitty
neovim
yazi
rmpc rmpcd mpd mpc
mpv
spicetify-cli
btop
fastfetch
matugen
oh-my-posh
zsh
chafa
cava
```

Most are available in the official Arch repos or AUR:

```bash
# Official repos
sudo pacman -S hyprland kitty neovim yazi mpd mpv btop fastfetch zsh chafa

# AUR
yay -S rmpc spicetify-cli matugen oh-my-posh
```

---

## Notes

- Configs are tailored to my specific setup and may need adjustments for yours
- Some scripts reference absolute paths to `/home/Dazed/` — you'll need to update these
- The rmpc layout uses a custom theme with cava visualizer, lyrics pane, and album art
- Hyprland uses the `scrolling` layout on the special music workspace

---

## License

[GPL-3.0](LICENSE)
