import subprocess

ip_cmd    = "adb shell ip route | awk '{print $9}'"
ip_output = subprocess.check_output(ip_cmd, shell=True)
ip_output = ip_output.strip()
print(ip_output)

