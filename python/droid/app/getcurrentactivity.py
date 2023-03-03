from pyutils.cli.clitools import run_cmd
from droid.adb.adb import AdbTools


def get_current_activity(target_device):
    adb_cmd = AdbTools.get_adb_cmd(
        target_device=target_device
    )
    get_current_activity_cmd = f"{adb_cmd} shell dumpsys activity activities"
    current_activity_output = run_cmd(get_current_activity_cmd)
    current_activity_output_lines = current_activity_output.split("\n")

    for line in current_activity_output_lines:
        target_token = "mFocusedApp"
        if target_token in line:
            target_line = line[line.index(target_token) + len(target_token) + 1:]
            target_line = target_line.replace("{", " ").replace("}", " ")
            print(target_line.split(" ")[3])
            

if __name__ == '__main__':
    import sys
    target_device = sys.argv[1] if len(sys.argv) > 1 else None
    get_current_activity(target_device)
