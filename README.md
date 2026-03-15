# Dotfiles

Personal Hyprland setup based on [JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland).
Customizations include rofi themes, waybar style, and various scripts.

## Fresh Install Process

1. Install Arch base system

2. Install stow:
   ```bash
   sudo pacman -S stow
   ```

3. Clone this repo:
   ```bash
   git clone https://github.com/ebrunco/dotfiles.git ~/dotfiles
   ```

4. Install packages from the saved package list:
   ```bash
   sudo pacman -S --needed - < ~/dotfiles/packages.txt
   ```

5. Remove any default configs that may already exist:
   ```bash
   rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/kitty ~/.config/swaync
   ```

6. Stow configs:
   ```bash
   cd ~/dotfiles
   stow hypr waybar rofi kitty swaync
   ```

7. Copy wallpapers to `~/Pictures/wallpapers`

## Notes
- `packages.txt` contains all explicitly installed packages at time of export — not just Hyprland dependencies
- Update and push `packages.txt` before setting up on a new machine:
  ```bash
  pacman -Qe > ~/dotfiles/packages.txt
  git add ~/dotfiles/packages.txt
  git commit -m "update package list"
  git push
  ```
- Wallpapers are not included in this repo (too large) — back them up separately
- Script permissions are preserved by git (saved as 755) so `chmod +x` should not be needed
