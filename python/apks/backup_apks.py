import subprocess, sys, traceback

apks_cmd    = "adb shell pm list packages | sed 's/:/ /g' | awk '{print $2}'"
apks = subprocess.check_output(apks_cmd, shell=True, stderr=subprocess.STDOUT)
apks = apks.decode('utf8').strip().split('\n')

apk_list = []

for a in apks:
    apk_list.append(a.strip())

apk_path_list = []

for a in apk_list:
    apk_path_cmd    = "adb shell pm path " + a + " | cut -c9- "
    apk_path = subprocess.check_output(apk_path_cmd, shell=True, stderr=subprocess.STDOUT)
    apk_path = apk_path.decode('utf8').strip()
    print(apk_path)
    apk_path_list.append(apk_path)

for i in xrange(0, len(apk_path_list)):
    print('Backup APK ' + apk_list[i])
    apk_bkp_cmd    = "mkdir " + apk_list[i] + " && adb pull " + apk_path_list[i] + ' ' + apk_list[i] + "/"
    # print(apk_bkp_cmd)
    try:
        subprocess.check_output(apk_bkp_cmd, shell=True, stderr=subprocess.STDOUT)
    except:
        pass
