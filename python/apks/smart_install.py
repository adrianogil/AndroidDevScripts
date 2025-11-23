#!/usr/bin/env python3
import argparse
import subprocess
import sys
from typing import List, Optional


def build_adb_base_args(device_name: Optional[str]) -> List[str]:
    args = ["adb"]
    if device_name:
        args += ["-s", device_name]
    return args


def run_adb_cmd(args: List[str]) -> str:
    """
    Run an adb command and return stdout as a stripped string.
    Raises subprocess.CalledProcessError on failure.
    """
    result = subprocess.run(
        args,
        check=True,
        capture_output=True,
        text=True,
    )
    # Combine stdout and stderr just in case adb prints to both.
    output = (result.stdout or "").strip()
    if not output and result.stderr:
        output = result.stderr.strip()
    return output


def install_apk(
    apk_path: str,
    device_name: Optional[str],
    replace_existing: bool,
) -> None:
    print(f"Installing APK {apk_path}")

    args = build_adb_base_args(device_name)
    args.append("install")
    if replace_existing:
        # -r: replace existing application
        args.append("-r")
    args.append(apk_path)

    output = run_adb_cmd(args)
    if output:
        print(output)


def uninstall_app(package_name: str, device_name: Optional[str]) -> None:
    print(f"Uninstalling package {package_name}")
    args = build_adb_base_args(device_name)
    args += ["uninstall", package_name]

    output = run_adb_cmd(args)
    if output:
        print(output)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Smart APK installer using adb (install, then uninstall+reinstall on certain errors)."
    )
    parser.add_argument("package_name", help="Application package name (e.g. com.example.app)")
    parser.add_argument("apk_path", help="Path to the APK file")
    parser.add_argument(
        "-s", "--device",
        dest="device_name",
        help="ADB device serial (passed as `adb -s <device>`)",
    )
    parser.add_argument(
        "-f", "--fresh-install",
        action="store_true",
        help="Force a clean install (do NOT use -r / replace flag on the first attempt).",
    )
    parser.add_argument(
        "--no-retry",
        action="store_true",
        help="Do not try uninstall+reinstall on INSTALL_FAILED_* errors.",
    )

    args = parser.parse_args()

    package_name: str = args.package_name
    apk_path: str = args.apk_path
    device_name: Optional[str] = args.device_name

    # If --fresh-install is passed, we do not use -r in the first attempt.
    replace_existing_first_attempt = not args.fresh_install

    try:
        install_apk(
            apk_path=apk_path,
            device_name=device_name,
            replace_existing=replace_existing_first_attempt,
        )
        return 0

    except subprocess.CalledProcessError as e:
        error_output = (e.output or "").strip()
        print("Got error from adb:", file=sys.stderr)
        if error_output:
            print(error_output, file=sys.stderr)

        if args.no_retry:
            # User explicitly disabled retry logic
            return e.returncode or 1

        # adb returns errors like INSTALL_FAILED_ALREADY_EXISTS etc.
        # Keep the same conditions you had.
        retriable_errors = (
            "INSTALL_FAILED_ALREADY_EXISTS",
            "INSTALL_FAILED_VERSION_DOWNGRADE",
            "INSTALL_FAILED_UPDATE_INCOMPATIBLE",
        )

        if any(code in error_output for code in retriable_errors):
            print("Detected install conflict. Trying uninstall + fresh install...")
            try:
                uninstall_app(package_name, device_name)
                # On second attempt, always use -r to avoid surprises.
                install_apk(
                    apk_path=apk_path,
                    device_name=device_name,
                    replace_existing=True,
                )
                return 0
            except subprocess.CalledProcessError as e2:
                error_output2 = (e2.output or "").strip()
                print("Second attempt failed:", file=sys.stderr)
                if error_output2:
                    print(error_output2, file=sys.stderr)
                return e2.returncode or 1

        # Not a retriable install error, just propagate the failure.
        return e.returncode or 1


if __name__ == "__main__":
    sys.exit(main())
