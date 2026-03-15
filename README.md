# Dotfiles

Personal Hyprland setup based on [JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland).
Customizations include rofi themes, waybar style, and various scripts.

## Fresh Install Process

1. Install Arch base system
2. Run JaKooLit's installer first to get all dependencies:
   ```bash
   git clone https://github.com/JaKooLit/Arch-Hyprland.git
   cd Arch-Hyprland
   chmod +x install.sh
   ./install.sh
   ```
3. Install stow:
   ```bash
   sudo pacman -S stow
   ```
4. Remove default configs JaKooLit created:
   ```bash
   rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/kitty ~/.config/swaync
   ```
5. Clone and stow this repo:
   ```bash
   git clone https://github.com/ebrunco/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow hypr waybar rofi kitty swaync
   ```
6. Copy wallpapers to `~/Pictures/wallpapers`

## Notes
- `packages.txt` contains all explicitly installed packages at time of export — not just Hyprland dependencies
- Update and push `packages.txt` before setting up on a new machine: `pacman -Qe > packages.txt`
- Wallpapers are not included in this repo (too large) — back them up separately
