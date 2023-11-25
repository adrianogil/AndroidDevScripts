import datetime

from pyutils.cli.clitools import run_cmd

from droid.app.appdetails import get_app_details
from droid.app.applist import get_list_installed_apps

import json


def get_full_device_info():
    """
    Retrieves the full device information including device model, version, kernel, Android API, Android SDK,
    processor architecture, GPU info, and installed apps.

    Returns:
        dict: A dictionary containing the device information and installed apps.
    """
    device_model = run_cmd("adb shell getprop ro.product.model")
    device_version = run_cmd("adb shell getprop ro.bootloader")
    device_kernel = run_cmd("adb shell cat /proc/version")
    device_android_api = run_cmd("adb shell getprop ro.build.version.release")
    device_android_sdk = run_cmd("adb shell getprop ro.build.version.sdk")
    device_processor_arch = run_cmd("adb shell getprop ro.product.cpu.abi")
    device_gpu_info = run_cmd("adb shell dumpsys SurfaceFlinger |grep GLES")

    apps_data = {}
    app_list = get_list_installed_apps()
    for app in app_list:
        try:
            app_details = get_app_details(app)
            apps_data[app] = app_details
        except:
            print("Error getting app details for %s" % app)
    return {
        "device": {
            "model": device_model,
            "model_version": device_version,
            "kernel": device_kernel,
            "android_api": device_android_api,
            "android_sdk": device_android_sdk,
            "processor_arch": device_processor_arch,
            "gpu_info": device_gpu_info
        },
        "apps": apps_data
    }


if __name__ == '__main__':
    device_info = get_full_device_info()

    device_name = device_info["device"]["model"]
    today_date = datetime.datetime.now().strftime('%Y_%m_%d')

    with open("device_info_%s_%s.json" % (device_name, today_date), 'w') as file_handler:
         json.dump(device_info, file_handler, indent=4)
