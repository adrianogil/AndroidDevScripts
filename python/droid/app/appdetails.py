from pyutils.cli.clitools import run_cmd
import sys


def extract_from_label(text, label, end=None):
    for line in text.split('\n'):
        if label in line:
            remain_line = line[line.index(label) + len(label):]
            if end:
                extracted_text = remain_line[:remain_line.index(end)]
                return extracted_text
            else:
                extracted_text = remain_line.strip()
                return extracted_text


def get_app_details(target_package):
	print("Loading information about app: %s" % (target_package,))

	adb_cmd_get_version = "adb shell dumpsys package %s | grep versionName" % (target_package,)
	version_text = run_cmd(adb_cmd_get_version)
	version_text = extract_from_label(text=version_text, label='versionName=')

	adb_cmd_get_apk_path = "adb shell pm list packages -f %s" % (target_package,)
	apk_path = run_cmd(adb_cmd_get_apk_path)
	apk_path = apk_path.replace('package:', '')

	# TODO: avoid copying manaully aapt-arm-pie bin
	adb_cmd_extract_data_from_apk = ["adb", "shell", "/data/local/tmp/aapt-arm-pie dump badging $(pm path %s | cut -c9-)" % (target_package,)]

	# print(adb_cmd_extract_data_from_apk)
	apk_data = run_cmd(adb_cmd_extract_data_from_apk, live_log=True)
	# print(apk_data)

	permissions = []

	for line in apk_data.split("\n"):
		if 'uses-permission:' in line:
			permissions.append(line[17:].replace("'", "").strip())

	app_name = extract_from_label(text=apk_data, label="application: label='", end="'")
	launchable_activity = extract_from_label(text=apk_data, label="launchable activity name='", end="'")

	app_details = {
		"app_name": app_name,
		"version": version_text,
		"apk_path": apk_path,
		"launchable_activity": launchable_activity,
		 "permissions": permissions
	}

	return app_details


if __name__ == '__main__':
	target_package = sys.argv[1]

	# TODO: select a android device

	app_details = get_app_details(target_package)

	print('\n')
	for app_field in app_details:
		print("%s: " % (app_field.replace("_", " ").capitalize(),), app_details[app_field])
	# print('App name: ', app_details['app_name'])
	# print('Version: %s' % (app_details['version_text'],))
	# print('APK path: %s' % (app_details['apk_path'],))
