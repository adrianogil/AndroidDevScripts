import subprocess, sys, traceback

package_name = sys.argv[1]
apk_path = sys.argv[2]

# print("smart_install - apk_path " + apk_path)

def install_apk(apk_path):
    print('Installing APK ' + apk_path)
    apk_install_cmd    = "adb install " + apk_path
    apk_install_output = subprocess.check_output(apk_install_cmd, shell=True, stderr=subprocess.STDOUT)
    apk_install_output = apk_install_output.strip().split('\n')
    apk_install_output = apk_install_output[0].strip()
    print(apk_install_output)

try:
    # apk_install_cmd    = "adb install " + apk_path
    # apk_install_output = subprocess.check_output(apk_install_cmd, shell=True)
    # apk_install_output = apk_install_output.strapk_install().split('\n')
    # apk_install_output = apk_install_output[0].strapk_install()
    # print(apk_install_output)
    install_apk(apk_path)
except subprocess.CalledProcessError as e:
    error_output = e.output.decode()
    print("Got error: " + error_output)
    if 'INSTALL_FAILED_ALREADY_EXISTS' in error_output or \
        'INSTALL_FAILED_VERSION_DOWNGRADE' in error_output:
        print("Let's uninstall current version from device!")
        # response = raw_input("Would you like to uninstall current version from device? (y) ")
        # if response == '\n' or response == 'y':
        #     print('uninstall')
        # else:
        #     print('do nothing')
        apk_uninstall_cmd    = "adb uninstall " + package_name
        apk_uninstall_output = subprocess.check_output(apk_uninstall_cmd, shell=True)
        apk_uninstall_output = apk_uninstall_output.strip().split('\n')
        apk_uninstall_output = apk_uninstall_output[0].strip()
        print(apk_uninstall_output)

        install_apk(apk_path)





