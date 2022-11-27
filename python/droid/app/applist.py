from pyutils.cli.clitools import run_cmd


def get_list_installed_apps(target_device=None):

    if target_device:
        adb_get_installed_apps_cmd = 'adb -s ${%s} shell pm list packages -f | sed "s/apk=/ /" | awk \'{print $2}\'' % (target_device,)
    else:
        adb_get_installed_apps_cmd = 'adb shell pm list packages -f | sed "s/apk=/ /" | awk \'{print $2}\''

    app_list_output = run_cmd(adb_get_installed_apps_cmd)

    installed_app_package_list = []

    for app in app_list_output.split('\n'):
        app_package = app.strip()
        installed_app_package_list.append(app_package)
    
    return installed_app_package_list


if __name__ == '__main__':
    installed_app_package_list = get_list_installed_apps()
    for app_package in installed_app_package_list:
        print("> " + app_package)
