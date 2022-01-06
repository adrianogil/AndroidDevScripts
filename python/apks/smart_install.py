# python2
import subprocess, sys, traceback

package_name = sys.argv[1]
apk_path = sys.argv[2]

device_name = None

if len(sys.argv) >= 4:
    device_name = sys.argv[3]

total_flags = len(sys.argv) - 3
flags = []
for i in range(0, total_flags):
    flags.append(sys.argv[3+i])

# print("smart_install - apk_path " + apk_path)

def install_apk(apk_path, only_install_mode=False):
    print('Installing APK ' + apk_path)
    
    apk_install_cmd = "adb "
    if device_name:
        apk_install_cmd += " -s " + device_name
    apk_install_cmd += " install "

    if not only_install_mode:
        apk_install_cmd += '-r '
    apk_install_cmd += apk_path

    apk_install_output = subprocess.check_output(apk_install_cmd, shell=True, stderr=subprocess.STDOUT)
    apk_install_output = apk_install_output.strip().split('\n')
    apk_install_output = apk_install_output[0].strip()
    print(apk_install_output)

try:
    only_install_mode_flag = '-f' in flags
    install_apk(apk_path, only_install_mode=only_install_mode_flag)
except subprocess.CalledProcessError as e:
    error_output = e.output.decode()
    print("Got error: " + error_output)
    if 'INSTALL_FAILED_ALREADY_EXISTS' in error_output or \
        'INSTALL_FAILED_VERSION_DOWNGRADE' in error_output or \
        'INSTALL_FAILED_UPDATE_INCOMPATIBLE' in error_output:
        print("Let's uninstall current version from device!")
        # response = raw_input("Would you like to uninstall current version from device? (y) ")
        # if response == '\n' or response == 'y':
        #     print('uninstall')
        # else:
        #     print('do nothing')
        apk_uninstall_cmd = "adb "
        if device_name:
            apk_uninstall_cmd += " -s " + device_name
        apk_uninstall_cmd += " uninstall " + package_name
        apk_uninstall_output = subprocess.check_output(apk_uninstall_cmd, shell=True)
        apk_uninstall_output = apk_uninstall_output.strip().split('\n')
        apk_uninstall_output = apk_uninstall_output[0].strip()
        print(apk_uninstall_output)

        install_apk(apk_path)
