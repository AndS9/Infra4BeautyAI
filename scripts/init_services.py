#!/usr/bin/env python3

import shutil
import subprocess
from pathlib import Path


SERVICES_DIR = Path("/home/developer/Infra4BeautyAI/services")
SYSTEMD_DIR = Path("/etc/systemd/system")

UNIT_SUFFIXES = {".service", ".timer"}
SCRIPT_NAMES = {"start.sh", "stop.sh"}


def run_command(*args):
    print(f"$ {' '.join(args)}")
    subprocess.run(args, check=True)


def make_executable(path: Path):
    """Add executable permissions to a file."""
    path.chmod(path.stat().st_mode | 0o111)
    print(f"Made executable: {path}")


def move_file(source: Path, destination: Path):
    """Move a file, replacing the destination if it already exists."""
    print(f"Moving {source} -> {destination}")

    if destination.exists():
        print(f"Warning: {destination} already exists, replacing it.")
        destination.unlink()

    shutil.move(str(source), str(destination))


def main():
    if not SERVICES_DIR.is_dir():
        raise SystemExit(f"Directory not found: {SERVICES_DIR}")

    # Find all .service and .timer files
    unit_files = [
        file
        for file in SERVICES_DIR.rglob("*")
        if file.is_file() and file.suffix in UNIT_SUFFIXES
    ]

    # Find all start.sh and stop.sh files
    script_files = [
        file
        for file in SERVICES_DIR.rglob("*")
        if file.is_file() and file.name in SCRIPT_NAMES
    ]

    if not unit_files and not script_files:
        print("No service units or scripts found.")
        return

    # ---------------------------------------------------------------
    # Make start.sh and stop.sh executable
    # ---------------------------------------------------------------

    for script in script_files:
        make_executable(script)

    # ---------------------------------------------------------------
    # Move .service and .timer files to systemd
    # ---------------------------------------------------------------

    for unit in unit_files:
        destination = SYSTEMD_DIR / unit.name
        move_file(unit, destination)

    # ---------------------------------------------------------------
    # Reload systemd configuration
    # ---------------------------------------------------------------

    if unit_files:
        run_command("systemctl", "daemon-reload")

    # ---------------------------------------------------------------
    # Detect .timer -> .service pairs
    # ---------------------------------------------------------------

    service_names = {
        file.name
        for file in unit_files
        if file.suffix == ".service"
    }

    timer_names = {
        file.name
        for file in unit_files
        if file.suffix == ".timer"
    }

    # ---------------------------------------------------------------
    # Enable/start timers
    # ---------------------------------------------------------------

    for timer in sorted(timer_names):
        service = timer.removesuffix(".timer") + ".service"

        if service in service_names:
            print(f"Detected pair: {service} <-> {timer}")
            print(f"Enabling and starting timer only: {timer}")
        else:
            print(f"Standalone timer: {timer}")

        run_command("systemctl", "enable", timer)
        run_command("systemctl", "start", timer)

    # ---------------------------------------------------------------
    # Enable/start standalone services
    # ---------------------------------------------------------------

    for service in sorted(service_names):
        timer = service.removesuffix(".service") + ".timer"

        if timer in timer_names:
            # Service is controlled by its timer.
            continue

        print(f"Standalone service: {service}")

        run_command("systemctl", "enable", service)
        run_command("systemctl", "start", service)

    print("\nDone.")


if __name__ == "__main__":
    main()
