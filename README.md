# Dotfiles
Personal Hyprland setup based on [JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland).
Customizations include rofi themes, waybar style, and various scripts.

## Fresh Install Process
1. Install Arch base system
2. Clone this repo:
```bash
   git clone https://github.com/ebrunco/dotfiles.git ~/dotfiles
```
3. Confirm system has necessary packages (e.g. kitty, hypr, waybar, swaync, rofi, etc)
```bash
   sudo pacman -S --needed - <packageNames>
```
4. Remove any default configs that may already exist or create backups
```bash
   rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/kitty ~/.config/swaync ~/Pictures/wallpapers
```
5. Stow configs and wallpapers:
```bash
   cd ~/dotfiles
   stow hypr waybar rofi kitty swaync wallpapers
```

## Notes
- Script permissions are preserved by git (saved as 755) so `chmod +x` should not be needed
