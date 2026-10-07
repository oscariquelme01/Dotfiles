# Hyprland + Noctalia

Minimal daily-driver setup for Hyprland 0.56 / Noctalia 5.

## Appearance and displays

- Vesper colors from Kitty: background `#101010`, active border `#ffc799`, inactive border `#282828`.
- Zero gaps, square corners, one-pixel borders. Borders disappear when a workspace
  contains only one visible window and return automatically at two or more.
  Floating windows count too.
- Laptop: `eDP-1`, 2880×1920 at 120 Hz, scale 2.
- External 5120×1440: scale 1.25; external 5120×2160: scale 5/3.
- LG ULTRAFINE serial `509NTFAL1091` is matched by identity, regardless of connector
  or initial mode. Currently uses its preferred 3440×1440 at ~100 Hz, scale 1,
  as a diagnostic baseline: forced 5120×2160 at 60 Hz / scale 5/3 looked wrong.
  Native-resolution configuration is pending display troubleshooting.
- Other external profiles recognize the active native resolution. Unrecognized
  displays use their preferred mode and automatic scale.
- `scripts/monitor-wallpaper.py` assigns `~/Wallpapers/5120x2160.png` to that LG
  by serial on hotplug and Noctalia startup. The laptop retains its own wallpaper.
  If another display reuses the LG's old port, its stale LG wallpaper is reset to
  the default. Noctalia persists per-connector paths; the hook translates identity
  to the current connector rather than hardcoding DP/HDMI names.
- External displays extend to the right. The laptop stays enabled when docked.
  Physical hotplug testing at both houses is still required.

## Shortcuts

`Super` is the Windows key. Existing shortcuts are retained unless noted.

| Shortcut | Action |
| --- | --- |
| Super+Enter | Kitty |
| Super+Q | Close window |
| Super+E | Dolphin |
| Super+R | Noctalia launcher |
| Super+Space | Switch US/Spanish keyboard layout |
| Super+L | Lock |
| Super+Ctrl+E | Session menu, **not** immediate logout |
| Super+A | Control center |
| Super+I | Noctalia settings |
| Super+Ctrl+V | Clipboard history |
| Super+N | Notification history |
| Super+Ctrl+N | Toggle DND |
| Super+Ctrl+C | Toggle caffeine (prevent idle actions) |
| Alt+Tab | Noctalia window switcher; release Alt to select |
| Super+arrows | Focus window |
| Super+Alt+H/J/K/L | Focus left/down/up/right |
| Super+Shift+arrows | Move window |
| Super+Ctrl+arrows | Resize window; hold to repeat |
| Super+V | Toggle floating |
| Super+Shift+V | Center floating window |
| Super+F / Super+Shift+F | Fullscreen / maximized |
| Super+backslash | Toggle dwindle split direction |
| Super+1…0 | Workspace 1…10 |
| Super+Shift+1…0 | Move window to workspace and follow |
| Super+Ctrl+Shift+1…0 | Send window without following |
| Super+Tab | Previous workspace |
| Super+PageUp/PageDown or wheel | Previous/next existing workspace |
| Super+comma/period | Focus left/right monitor |
| Super+Shift+comma/period | Move window to left/right monitor and follow |
| Super+S | Move current workspace to next monitor and follow (cycles) |
| Super+P / Super+Ctrl+P / Print | Frozen region screenshot |
| Shift+Print | Screenshot focused monitor |
| Ctrl+Print | Screenshot all monitors |
| Super+Shift+P | Frozen screenshot annotation editor |
| Super+left/right mouse drag | Move/resize window |

Audio, microphone, brightness and playback keys use Noctalia directly, including
while locked. Kitty/Neovim's Ctrl+H/J/K/L shortcuts are left alone.

### Screenshots

The region selector uses **Ctrl+C to copy only**, **Ctrl+S to save only**, or
**Enter to copy and save**. Escape cancels. Files go to `~/Pictures/Screenshots`.
Noctalia has a global screenshot policy, so both legacy region bindings open the
same selector instead of separate instant-copy and instant-save commands.

## Services and configuration

Noctalia owns the bar, wallpaper, notification daemon, clipboard history, polkit
agent, lock screen and idle management. There are no Waybar/Hyprpaper/Wofi/
Hyprshot/Grimblast/Hyprlock/Hypridle launch commands in this configuration.

- Lock after 300 seconds idle; screen off after 600 seconds idle.
- Automatic suspend is disabled. Lock-before-suspend is enabled.
- Existing Noctalia Vesper palette, wallpaper, bar and dock settings are preserved.
- Curated settings: `~/.config/noctalia/config.toml`.
- GUI overrides: `~/.local/state/noctalia/settings.toml` (these win over curated settings).
- Noctalia clipboard history currently works in-session. Its log reports no Secret
  Service provider, so encrypted persistent history/keyring integration needs a
  separate follow-up; this configuration does not install a credential provider.
- Noctalia Greeter/greetd setup and recovery: `greetd/README.md`.
  Its system installation requires `sudo bash ~/.config/hypr/greetd/install.sh`.
  Old-package removal remains deferred.
- The old example mouse override was omitted; qt5ct was not carried forward
  because neither qt5ct nor qt6ct is installed.

## Validation and recovery

```sh
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
hyprctl reload
hyprctl configerrors
noctalia config validate
```

`hyprland.lua.pre-noctalia` is a backup of the Lua config before this migration;
`hypr.conf-old` remains untouched. To restore the original Lua config:

```sh
cp ~/.config/hypr/hyprland.lua.pre-noctalia ~/.config/hypr/hyprland.lua
hyprctl reload
```

That only restores Hyprland. To also disable the new Noctalia baseline while
retaining your GUI settings, rename `~/.config/noctalia/config.toml` to
`config.toml.disabled` (Noctalia loads only `.toml` files).

Before retiring legacy packages, manually test lock/unlock, both keyboard layouts,
region copy/save, clipboard selection, media/brightness keys, a polkit prompt,
idle screen-off and wake, suspend/resume, external hotplug and a fresh login.
