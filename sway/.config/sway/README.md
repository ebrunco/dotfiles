# Sway Config — Fedora Migration Guide

Migrated from Hyprland (JaKooLit dots). This documents the full setup, required packages, and what carries over vs. what changed.

---

## Directory Layout

Everything lives under `~/.config/sway/` — no separate `swaylock/` or `swayidle/` directories needed.

```
~/.config/sway/
├── config              # Main sway config (keybinds, outputs, rules, startup)
├── swaylock.conf       # Lock screen colors/settings (passed via --config flag)
├── scripts/            # All scripts — Sway rewrites + copies from hypr
│   ├── LockScreen.sh   # Calls swaylock --config ~/.config/sway/swaylock.conf
│   ├── Refresh.sh      # Restarts waybar + swaync
│   ├── Wlogout.sh      # Uses swaymsg instead of hyprctl
│   ├── ScreenShot.sh   # Uses swaymsg -t get_tree instead of hyprctl activewindow
│   ├── GameMode.sh     # Toggles gaps/borders via swaymsg
│   ├── Dropterminal.sh # Sway marks + scratchpad (no hyprctl)
│   └── ...             # Copied scripts from hypr (see list below)
└── README.md           # This file

~/.config/environment.d/
└── wayland.conf        # Env vars loaded by systemd (replaces ENVariables.conf)

~/.config/swaync/       # Left in its own directory — needs config.json, style.css, icons/, images/
~/.config/waybar/       # Left in its own directory — no changes needed
```

> **swayidle** has no config file — it is configured entirely via the `exec swayidle -w ...`
> command inline in `~/.config/sway/config`. There is no `~/.config/swayidle/` directory.

---

## Required Packages (Fedora / dnf)

```bash
# Core
sudo dnf install sway swayidle swaylock

# Bar & notifications
sudo dnf install waybar swaync

# App launcher
sudo dnf install rofi

# Terminal & file manager
sudo dnf install kitty yazi

# Screenshot tools
sudo dnf install grim slurp swappy

# Clipboard
sudo dnf install wl-clipboard
# cliphist is not in Fedora repos — install from GitHub releases or via cargo:
# cargo install cliphist

# Wallpaper daemon
sudo dnf install swww
# If swww is not in repos, fall back to: sudo dnf install swaybg

# Power menu
sudo dnf install wlogout

# Polkit agent
sudo dnf install polkit-gnome

# Tray / networking / bluetooth
sudo dnf install network-manager-applet blueman udiskie

# Media & volume
sudo dnf install playerctl pamixer

# Brightness (laptop)
sudo dnf install brightnessctl

# Fonts
sudo dnf install jetbrains-mono-fonts
# Nerd Font variant: https://www.nerdfonts.com/ → extract to ~/.local/share/fonts/

# Cursor theme (Bibata-Modern-Ice)
# Download from https://github.com/ful1e5/Bibata_Cursor/releases
# Extract to ~/.local/share/icons/
```

---

## Scripts Setup

### Scripts already rewritten for Sway

Do **not** copy these from your old hypr config — they live in `~/.config/sway/scripts/` and use `swaymsg` instead of `hyprctl`:

| Script | What changed |
|--------|-------------|
| `LockScreen.sh` | Calls `swaylock --config ~/.config/sway/swaylock.conf` |
| `ScreenShot.sh` | `hyprctl activewindow` → `swaymsg -t get_tree` |
| `GameMode.sh` | `hyprctl keyword` → `swaymsg` for gaps/borders |
| `Wlogout.sh` | `hyprctl monitors` → `swaymsg -t get_outputs` |
| `Refresh.sh` | Removed hyprctl dependency |
| `Dropterminal.sh` | Complete rewrite using Sway marks + scratchpad |

### Scripts to copy from your old hypr config

These work unchanged. Copy them to `~/.config/sway/scripts/` then run the path fix below:

```
Volume.sh         MediaCtrl.sh       Brightness.sh      BrightnessKbd.sh
ClipManager.sh    RofiEmoji.sh       RofiSearch.sh      RofiCalc.sh
RofiBeats.sh      WaybarLayout.sh    WaybarStyles.sh    WaybarScripts.sh
Sounds.sh         DarkLight.sh       WallpaperSelect.sh WallpaperRandom.sh
WallpaperEffects.sh  KeyBinds.sh     Kool_Quick_Settings.sh
WeatherWrap.sh    Weather.sh         Weather.py
```

Copy command (run from your old machine before the move):

```bash
scripts=(
  Volume.sh MediaCtrl.sh Brightness.sh BrightnessKbd.sh
  ClipManager.sh RofiEmoji.sh RofiSearch.sh RofiCalc.sh RofiBeats.sh
  WaybarLayout.sh WaybarStyles.sh WaybarScripts.sh Sounds.sh DarkLight.sh
  WallpaperSelect.sh WallpaperRandom.sh WallpaperEffects.sh
  KeyBinds.sh WeatherWrap.sh Weather.sh
)
for s in "${scripts[@]}"; do
  cp ~/.config/hypr/scripts/$s ~/.config/sway/scripts/$s 2>/dev/null
  cp ~/.config/hypr/UserScripts/$s ~/.config/sway/scripts/$s 2>/dev/null
done
cp ~/.config/hypr/UserScripts/Weather.py ~/.config/sway/scripts/Weather.py 2>/dev/null

# Fix internal path references
sed -i 's|\.config/hypr/scripts|.config/sway/scripts|g' ~/.config/sway/scripts/*.sh
sed -i 's|\.config/hypr/UserScripts|.config/sway/scripts|g' ~/.config/sway/scripts/*.sh
```

Then make everything executable:

```bash
chmod +x ~/.config/sway/scripts/*.sh
```

---

## First Boot Checklist

1. **Log into Sway** via your display manager or from TTY:
   ```bash
   exec sway
   ```

2. **Confirm environment variables loaded:**
   ```bash
   echo $XDG_CURRENT_DESKTOP   # → sway
   echo $WAYLAND_DISPLAY        # → wayland-1
   ```
   If blank, add to `~/.bash_profile` or `~/.zprofile`:
   ```bash
   export XDG_CURRENT_DESKTOP=sway
   export XDG_SESSION_TYPE=wayland
   ```

3. **Confirm output name** — it will probably differ from `DP-2` on the new machine:
   ```bash
   swaymsg -t get_outputs
   ```
   Update the `output` line in `~/.config/sway/config` accordingly.

4. **Set a wallpaper:**
   ```bash
   swww-daemon &
   swww img ~/Pictures/wallpapers/your-wallpaper.png
   ```

5. **Check polkit agent path** — may differ on Fedora:
   ```bash
   ls /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
   ls /usr/libexec/polkit-gnome-authentication-agent-1
   ```
   Update the matching `exec` line in `~/.config/sway/config`.

6. **Test the lock screen:**
   ```bash
   swaylock --config ~/.config/sway/swaylock.conf
   ```
   To use your wallpaper as the lock background, uncomment the `image=` line in `swaylock.conf`.

7. **Copy scripts** (see section above) and run the path fix.

8. **Install cursor theme** and apply via nwg-look or `~/.config/gtk-3.0/settings.ini`:
   ```ini
   [Settings]
   gtk-cursor-theme-name=Bibata-Modern-Ice
   gtk-cursor-theme-size=24
   ```

---

## Waybar Module Fix

If your waybar config has Hyprland-specific modules, swap them:

| Old (Hyprland) | New (Sway) |
|----------------|------------|
| `hyprland/workspaces` | `sway/workspaces` |
| `hyprland/window` | `sway/window` |
| `hyprland/mode` | `sway/mode` |
| `hyprland/language` | `sway/language` |

Example replacement in `~/.config/waybar/config`:
```json
"sway/workspaces": {
    "disable-scroll": true,
    "all-outputs": false,
    "format": "{name}"
}
```

---

## Key Differences from Hyprland

| Feature | Hyprland | Sway |
|---------|----------|------|
| Blur / rounded corners | Built-in | Not in stock Sway — use SwayFX |
| Animations | Built-in | Not available |
| Groups | `togglegroup` / `changegroupactive` | `layout tabbed` (`$mod+G`) |
| Special workspace | `togglespecialworkspace` | Scratchpad (`$mod+U`) |
| Autotiling (dwindle) | Built-in | Install `autotiling` via pip |
| Config reload | `hyprctl reload` | `$mod+Shift+R` or `swaymsg reload` |
| Window info | `hyprctl activewindow` | `swaymsg -t get_tree` |
| Monitor info | `hyprctl monitors` | `swaymsg -t get_outputs` |
| Idle config | `~/.config/hypr/hypridle.conf` | CLI args in the `exec swayidle` line |
| Lock config | `~/.config/hypr/hyprlock.conf` | `~/.config/sway/swaylock.conf` |

### SwayFX (optional — for blur and rounded corners)

SwayFX is a drop-in Sway fork that adds blur, shadows, and rounded corners. The config syntax is identical — `~/.config/sway/config` works unchanged.

```bash
# Check for COPR packages first:
sudo dnf copr enable somecopr/swayfx
sudo dnf install swayfx

# Or build from source:
# https://github.com/WillPower3309/swayfx
```

### Autotiling (optional — dwindle equivalent)

```bash
pip install autotiling
```

Add to `~/.config/sway/config`:
```
exec autotiling
```

---

## Useful Commands

```bash
swaymsg -t get_outputs      # list monitors and their names
swaymsg -t get_inputs       # list input devices
swaymsg -t get_tree         # full window tree (use with jq)
swaymsg -t get_workspaces   # list workspaces
swaymsg reload              # reload config without restarting
swaylock --config ~/.config/sway/swaylock.conf   # test lock screen
```
