# Dotfiles
Personal Hyprland setup based on [JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland).
Customizations include rofi themes, waybar style, and various scripts.

## Fresh Install Process
1. Install Arch base system
2. Clone this repo:
```bash
   git clone https://github.com/ebrunco/dotfiles.git ~/dotfiles
```
3. Install packages from the saved package list:
```bash
   sudo pacman -S --needed - < ~/dotfiles/packages.txt
```
4. Remove any default configs that may already exist:
```bash
   rm -rf ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/kitty ~/.config/swaync ~/Pictures/wallpapers
```
5. Stow configs and wallpapers:
```bash
   cd ~/dotfiles
   stow hypr waybar rofi kitty swaync wallpapers
```

## Notes
- `packages.txt` contains all explicitly installed packages at time of export — not just Hyprland dependencies
- Update and push `packages.txt` before setting up on a new machine:
```bash
  pacman -Qe > ~/dotfiles/packages.txt
  git add ~/dotfiles/packages.txt
  git commit -m "update package list"
  git push
```
- To update wallpapers, add/remove files in `~/Pictures/wallpapers/` then:
```bash
  cd ~/dotfiles
  git add .
  git commit -m "update wallpapers"
  git push
```
- Similar process for updating other configs
- Script permissions are preserved by git (saved as 755) so `chmod +x` should not be needed
