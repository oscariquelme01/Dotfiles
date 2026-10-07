# Noctalia Greeter / greetd

Packages: `greetd` and `noctalia-greeter` (tested package version 1.6.0).

The curated files in this folder are installed into the system by:

```sh
sudo bash ~/.config/hypr/greetd/install.sh
```

This backs up existing configuration under `/var/backups/noctalia-greeter/`,
installs the greeter configuration and a copy of `~/Wallpapers/2880x1920.png`,
disables both `ly@tty1` and `ly@tty2` for future boots, and enables greetd.
It does **not** stop Ly or start greetd in the running session.

## Defaults

- Login on tty1, `topi` preselected, password required; Escape returns to user picker.
- Session: **Hyprland**, launching the existing `/usr/bin/start-hyprland` entry.
- Vesper palette, dark mode, no brand logo, current laptop wallpaper.
- US/Spanish keyboard layouts, Super+Space switches between them.
- Laptop `eDP-1` scale 2; other outputs use automatic scaling.
- Greeter blanks after five minutes without input.
- No automatic login, no passwordless sudo/Polkit rules, no custom PAM changes.
  The package already adds its required `pam_systemd` session integration.

Administrator-controlled appearance is pinned in `greeter.toml` and wins over
Noctalia's Sync. No auto-sync is needed for this baseline. Remembered UI state
and future appearance sync live separately in `/var/lib/noctalia-greeter/sync.toml`.
The wallpaper is copied outside your home so the greeter can read it before login.

For another machine, change `[user].default` to its login account before installing.
The installer uses that user's wallpaper directory. Adjust the wallpaper if needed.

## Check before reboot

```sh
systemctl is-enabled greetd.service ly@tty1.service ly@tty2.service
sudo -u greeter test -r /var/lib/noctalia-greeter/greeter.toml
sudo -u greeter test -r /var/lib/noctalia-greeter/wallpaper-vesper.png
```

Expected service state: **enabled, disabled, disabled**. Existing Ly processes
remaining active until reboot is intentional.

## Recovery

If login fails, switch to another TTY with Ctrl+Alt+F3, log in, and inspect:

```sh
sudo systemctl status greetd --no-pager
sudo journalctl -b -u greetd --no-pager
```

To return to Ly, from that recovery TTY:

```sh
sudo systemctl disable --now greetd.service
sudo systemctl enable ly@tty1.service
sudo reboot
```

Do not re-enable both Ly instances. Your home Hyprland/Noctalia configs and the
installed Ly package are untouched by the display-manager cutover.
