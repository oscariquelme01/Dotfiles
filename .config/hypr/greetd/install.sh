#!/usr/bin/env bash
# Run from your own terminal: sudo bash ~/.config/hypr/greetd/install.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo from your terminal." >&2
    exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
login_user=${SUDO_USER:-topi}
login_home=$(getent passwd "$login_user" | cut -d: -f6)
wallpaper="$login_home/Wallpapers/2880x1920.png"

[[ -x /usr/bin/noctalia-greeter-session ]]
getent passwd greeter >/dev/null
[[ -f "$wallpaper" ]]
[[ -f "$source_dir/config.toml" && -f "$source_dir/greeter.toml" ]]

# Validate all inputs before touching system configuration.
python - "$source_dir" "$login_user" <<'PY'
import pathlib, sys, tomllib
root = pathlib.Path(sys.argv[1])
with (root / 'config.toml').open('rb') as file:
    config = tomllib.load(file)
with (root / 'greeter.toml').open('rb') as file:
    greeter = tomllib.load(file)
assert config['default_session']['command'] == '/usr/bin/noctalia-greeter-session'
assert config['terminal']['vt'] == 1
assert 'initial_session' not in config, 'Automatic login is not allowed'
assert greeter['user']['default'] == sys.argv[2], 'Update greeter.toml for this machine\'s user first'
assert greeter['session']['default'] == 'Hyprland'
PY

backup="/var/backups/noctalia-greeter/$(date +%Y%m%d-%H%M%S)-$$"
install -d -o root -g root -m 0700 "$backup"
if [[ -f /etc/greetd/config.toml ]]; then
    cp -a /etc/greetd/config.toml "$backup/greetd-config.toml"
fi
if [[ -f /var/lib/noctalia-greeter/greeter.toml ]]; then
    cp -a /var/lib/noctalia-greeter/greeter.toml "$backup/greeter.toml"
fi
systemctl is-enabled ly@tty1.service ly@tty2.service greetd.service >"$backup/services-before.txt" || true

install -d -o root -g root -m 0755 /etc/greetd
install -d -o greeter -g greeter -m 0750 /var/lib/noctalia-greeter
install -o root -g root -m 0644 "$source_dir/config.toml" /etc/greetd/config.toml
install -o root -g greeter -m 0640 "$source_dir/greeter.toml" /var/lib/noctalia-greeter/greeter.toml
install -o root -g greeter -m 0640 "$wallpaper" /var/lib/noctalia-greeter/wallpaper-vesper.png

# Next boot only. Never use --now here: the current session belongs to Ly on tty2.
systemctl disable ly@tty1.service ly@tty2.service
systemctl enable greetd.service

echo "Configured Noctalia Greeter for the next boot; this session remains running."
echo "Backups: $backup"
echo "Check: systemctl is-enabled greetd.service ly@tty1.service ly@tty2.service"
echo "Expected: enabled, disabled, disabled. Reboot when ready."
