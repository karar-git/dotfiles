# Dotfiles

My personal configuration files for Arch Linux with Hyprland.

## What's Included

| Config | Description |
|--------|-------------|
| **alacritty** | GPU-accelerated terminal emulator |
| **hypr** | Hyprland window manager config, keybinds, animations, and scripts |
| **nvim** | Neovim setup based on Kickstart with custom plugins (Avante AI, Copilot) |
| **waybar** | Status bar with custom modules (CPU/GPU temp, power, network, media) |

## Installation

```bash
# Clone to your config directory
git clone https://github.com/karar-git/dotfiles.git ~/.config-backup

# Copy what you need
cp -r ~/.config-backup/alacritty ~/.config/
cp -r ~/.config-backup/hypr ~/.config/
cp -r ~/.config-backup/nvim ~/.config/
cp -r ~/.config-backup/waybar ~/.config/
```

## Dependencies

- **Hyprland** - Wayland compositor
- **Waybar** - Status bar
- **Alacritty** - Terminal
- **Neovim** - Text editor
- **wofi** - Application launcher
- **hyprpaper** - Wallpaper
- **wlogout** - Logout menu
- **grimblast** - Screenshots

## Keybinds (Hyprland)

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal |
| `Super + D` | App launcher |
| `Super + Q` | Close window |
| `Super + M` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + W` | Browser |
| `Super + P` | File manager |
| `Super + A` | Screenshot |
| `Super + B` | Toggle waybar |

## Notes

- Neovim requires `OPENAI_API_KEY` environment variable for AI features
- Some waybar modules require additional packages (cava, sensors, etc.)
