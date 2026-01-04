# AndroidDevScripts

A collection of shell aliases and helper scripts for day-to-day Android development, centered around `adb` workflows. The entrypoint is `bashrc.sh`, which wires up the functions in `dev/*.sh` and a few Python helpers.

## Features

### Device management
- **List devices:** `droid`
- **Pick a device (fuzzy finder when multiple):** `droid-device`
- **Open a shell:** `droid-shell`
- **Reboot:** `droid-reboot`
- **Quick device info summary:** `droid-device-info`
- **Scrcpy session (optional port):** `droid-scrcpy [port]`

### APK install, launch, and info
- **Smart install with metadata + launch:** `ikc` (alias for `droid-install-apk`)
- **Simple install:** `ik` / `droid-apk-install`
- **Uninstall from APK in cwd:** `uk`
- **Launch from APK:** `droid-apk-launch [apk_path]`
- **Launch by package name:** `launch_package <package> [device]`
- **Get APK permissions:** `apk_permissions [apk_path]`
- **Get package name from APK:** `get_package_name_from_apk <apk_path>`
- **List APKs/AARs in tree:** `apks`, `apks -d`, `aars`, `aars -d`

### App inspection + actions
- **Current activity:** `droid-app-get-current-activity [device]`
- **Open activity (interactive):** `droid-app-open-activity [activity]`
- **App details (Python helper):** `droid-app-detail [package]`
- **List permissions:** `droid-app-list-permissions [package] [device]`
- **Grant permission:** `droid-app-add-permission <package> <permission>`
- **Run as app user:** `droid-app-run-as [device] [package] <command...>`

### Logcat tooling
- **Save logcat to file:** `dlog [suffix]`
- **View last log:** `catlog [suffix]`
- **Search last log:** `logtext <string> [suffix]`
- **Unity log helpers:** `logunity`, `logunityexception`, `logunitypid`
- **Filter exceptions:** `logexception` / `catexception`
- **Clear/augment logcat:** `clrcat`, `augcat`
- **Stream logcat:** `droid-cat`

### File helpers on device
- **Open arbitrary file on device:** `droid-open <file>` (alias: `dp`)
- **Open text file in DroidEdit (tmp):** `dp-txt`, `dp-txt-reload`
- **Open PDF/model/text:** `droid-open-pdf`, `droid-open-model`, `droid-open-text`
- **Open file details for app:** `droid-open-settings-pgk <package>`

### Screenshots + UI dumps
- **Grab a screenshot:** `droid-get-screenshot [device]`
- **Dump UI XML:** `droid-get-ui-xml [filename]`

### Networking + diagnostics
- **Wi‑Fi connect (adb tcpip):** `devdroid-connect-wifi`
- **Get WLAN IP (Python helper):** `droid-get-ipaddress-wlan`
- **CPU info by package:** `droid-cpuinfo-pkg <package>`
- **ANR traces:** `droid-get-anr-traces [suffix]`

### VR / Oculus helpers
- **Save/find OSIG:** `saveosig`, `findosig`, `copyallosig`
- **Install OVR Metrics Tool:** `ovr-install-metrics-tools`

### Fuzzy command palette
- **Interactive picker (alias):** `d` (backed by `droid-fz`)
  - Pulls commands annotated with `# droidtool` in the `dev/*android*.sh` scripts.

## Installation

Add the following lines to your `~/.bashrc` (or `~/.zshrc`):

```bash
export ANDROID_DEV_SCRIPTS_DIR=/<path-to>/AndroidDevScripts
source ${ANDROID_DEV_SCRIPTS_DIR}/bashrc.sh
```

### Requirements
- `adb` must be installed and on your `PATH`.
- Optional but recommended:
  - `fzf` (or another tool exposed as `default-fuzzy-finder`)
  - `scrcpy` for screen mirroring
  - `gfind` (GNU find) for better sorting on macOS
- Python helpers live in `python/` and are invoked via `python3 -m ...`.

## Contributing

Feel free to submit PRs. I will do my best to review and merge them if I consider them essential.

## Development status

This is a very alpha software. The code was written with no consideration of coding standards and architecture. A refactoring would do it good...

## Interesting Android development resources

- https://github.com/mzlogin/awesome-adb/blob/master/README.en.md#device-connection-management
