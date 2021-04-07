from pyutils.cli.clitools import run_cmd
from pyutils.parserstr import extract_from_label
import sys

target_package = sys.argv[1]

print("Loading information about app: %s" % (target_package,))

adb_cmd_get_version = "adb shell dumpsys package %s | grep versionName" % (target_package,)
version_text = run_cmd(adb_cmd_get_version)
version_text = extract_from_label(text=version_text, label='versionName=')

adb_cmd_get_apk_path = "adb shell pm list packages -f %s" % (target_package,)
apk_path = run_cmd(adb_cmd_get_apk_path)
apk_path = apk_path.replace('package:', '')

adb_cmd_extract_data_from_apk = ["adb", "shell", "/data/local/tmp/aapt-arm-pie dump badging $(pm path %s | cut -c9-)" % (target_package,)]

# print(adb_cmd_extract_data_from_apk)
apk_data = run_cmd(adb_cmd_extract_data_from_apk, using_popen=True)
# print(apk_data)

app_name = extract_from_label(text=apk_data, label="application: label='", end="'")

print('\n')
print('App name: ', app_name)
print('Version: %s' % (version_text,))
print('APK path: %s' % (apk_path,))
