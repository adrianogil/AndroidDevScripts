import os


class AdbTools:

    def __init__(self, adb_data=None):
        self.adb_data = adb_data


    def get_adb_cmd(self=None, 
            target_device=None, 
            target_port=None, 
            adb_path=None):
        """ 
            Returns the adb command considering: 
            - the path to adb command
            - current device
        """

        if self and self.adb_data is not None:
            target_port = adb_data['port']
            target_device = adb_data['device']
            adb_path = adb_data['adb_exe']

        port_cmd = ""
        if target_port is not None:
            port_cmd = f" -P {target_port}"

        device_cmd = ""
        if target_device is not None:
            device_cmd = f" -s {target_device}"

        if adb_path is None:
            # In this case, it considers that adb is in the current path
            if os.name == "nt":
                adb_exe = "adb.exe"
            else:
                adb_exe = "adb" 
        else:
            adb_exe = adb_path

        return f"{adb_exe}{device_cmd}{port_cmd}"
