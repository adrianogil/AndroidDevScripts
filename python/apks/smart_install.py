import subprocess, sys, traceback

package_name = sys.argv[1]
apk_path = sys.argv[2]

device_name = None

if len(sys.argv) >= 4:
    device_name = sys.argv[3]

total_flags = len(sys.argv) - 4
flags = []
for i in range(0, total_flags):
    flags.append(sys.argv[4+i])

# print("smart_install - apk_path " + apk_path)


def get_adb_cmd():
    apk_install_cmd = "adb "
    if device_name:
        apk_install_cmd += " -s " + device_name
    return apk_install_cmd


def run_adb_cmd(cmd):
    cmd = get_adb_cmd() + " " + cmd
    cmd_output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
    cmd_output = cmd_output.strip().split('\n')
    cmd_output = cmd_output[0].strip()

    return cmd_output


def install_apk(apk_path, only_install_mode=False):
    print('Installing APK ' + apk_path)
    
    apk_install_cmd = " install "

    if not only_install_mode:
        apk_install_cmd += '-r '
    apk_install_cmd += '"%s"' % (apk_path,)
    apk_install_output = run_adb_cmd(apk_install_cmd)
    
    print(apk_install_output)


def uninstall_app(package_name):
    print(f"Uninstalling package {package_name}")
    
    apk_uninstall_cmd = ' uninstall "%s"' % (package_name,)
    apk_uninstall_output = run_adb_cmd(apk_uninstall_cmd)
    
    print(apk_uninstall_output)


def install_app(package_name):
    print(f"Installing app {package_name}")
    only_install_mode_flag = '-f' in flags or '--reinstall' in flags
    install_apk(apk_path, only_install_mode=only_install_mode_flag)


try:
    install_app(package_name)
    
except subprocess.CalledProcessError as e:
    error_output = e.output.decode()
    print("Got error: " + error_output)
    if 'INSTALL_FAILED_ALREADY_EXISTS' in error_output or \
        'INSTALL_FAILED_VERSION_DOWNGRADE' in error_output or \
        'INSTALL_FAILED_UPDATE_INCOMPATIBLE' in error_output:
        print("Let's uninstall current version from device!")
        try:
            uninstall_app(package_name)
            install_app(package_name)
        except subprocess.CalledProcessError as e2:
            error_output = e2.output.decode()
            print("Got error: " + error_output)

