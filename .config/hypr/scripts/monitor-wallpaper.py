"""Apply the LG wallpaper by serial, independently of its current connector."""

import json
from pathlib import Path
import subprocess
import sys
import time


LG_SERIAL = "509NTFAL1091"
LG_WALLPAPER = str(Path.home() / "Wallpapers" / "5120x2160.png")


def run(*command):
    result = subprocess.run(
        command, check=True, capture_output=True, text=True, timeout=3
    )
    output = result.stdout.strip()
    if output.lower().startswith("error:"):
        raise RuntimeError(output)
    return output


def apply():
    monitors = json.loads(run("hyprctl", "monitors", "-j"))
    default = run("noctalia", "msg", "wallpaper-get")
    for monitor in monitors:
        connector = monitor["name"]
        current = run("noctalia", "msg", "wallpaper-get", connector)
        if monitor.get("serial") == LG_SERIAL:
            if not Path(LG_WALLPAPER).is_file():
                raise RuntimeError(f"Missing monitor wallpaper: {LG_WALLPAPER}")
            desired = LG_WALLPAPER
        elif current == LG_WALLPAPER:
            # Another display has reused a connector previously occupied by the LG.
            # Restore the default rather than leaking the LG assignment to it.
            desired = default
        else:
            # Preserve other displays' wallpaper choices, including the laptop.
            continue
        if current != desired:
            run("noctalia", "msg", "wallpaper-set", connector, desired)


def main():
    # Hotplug events can precede Noctalia's output discovery. Retry outside Hyprland.
    for attempt in range(6):
        try:
            apply()
            return 0
        except (subprocess.SubprocessError, RuntimeError, OSError, ValueError) as error:
            if attempt == 5:
                print(f"Monitor wallpaper: {error}", file=sys.stderr)
                return 1
            time.sleep(0.5)


if __name__ == "__main__":
    sys.exit(main())
