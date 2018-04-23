
# Install Android APK
function ik()
{
    echo 'Searching for APK files ...'

    apk_file=$(find . -name '*.apk' | head -1)

    if [ -z $apk_file ]; then
        echo 'No APK Found!'
    else
        echo 'Found '$apk_file
        adb install -r $apk_file
    fi
}

# Install Android APK
function ikc()
{
    apk_file=$1
    apk_date=$(date -r $apk_file)
    echo "Installing APK "$apk_file
    echo " -> build size: "$(du -sh $apk_file | awk '{print $1}')
    echo " -> build time: "$apk_date
    adb install -r $apk_file
    echo "Clear logcat"
    adb logcat -c
    echo "Augment logcat buffer to 64MB"
    adb logcat -G 64M
    echo "Launch Activity from APK "$apk_file
    launch_from_apk $apk_file

}

function get_package_name_from_apk()
{
     $ANDROID_SDK/build-tools/26.0.2/aapt dump badging $1 | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g
}

# Uninstall android app
function uk()
{
    echo 'Searching for APK info ...'

    apk_file=$(find . -name '*.apk' | head -1)

    if [ -z $apk_file ]; then
        echo 'No APK Found!'
    else
        echo 'Found '$apk_file
        echo ' '

        package_name=$(get_package_name_from_apk $apk_file)

        echo 'Uninstalling '$package_name
        adb uninstall $package_name
    fi
}

function launch_from_apk()
{
    apk_file=$1
    if [ -z $apk_file ]; then
        apk_file=$(find . -name '*.apk' | head -1)
    fi

    echo "Let's launch Activity from "$apk_file

    pkg_name=$(get_package_name_from_apk $apk_file)

    echo "Package "$pkg_name

    launch_package $pkg_name
}

# Launch Application from package name
function launch_package()
{
    adb shell monkey -p $1 -c android.intent.category.LAUNCHER 1
}

# Install and launch Android APK
function ikl()
{
    echo 'Searching for APK files ...'

    apk_file=$(find . -name '*.apk' | head -1)

    if [ -z $apk_file ]; then
        echo 'No APK Found!'
    else
        echo 'Found '$apk_file
        adb install -r $apk_file
        package_name=$(get_package_name_from_apk $apk_file)
        echo 'Installed '$package_name
        echo 'Launching Application...'
        launch_package $package_name
    fi
}

# Android logcat
function dlog()
{
    if [ -z $1 ]; then
        log_sufix=""
    else
        log_sufix="_"$1
    fi
    device_model=$(adb shell getprop ro.product.model)
    echo "Device is $device_model"
    log_file=log_${device_model}_$(date +%F-%H:%M)$log_sufix.txt
    echo 'Android log saved as '$log_file
    adb shell logcat -d -v time > $log_file
    number_of_lines=$(cat $log_file | wc -l)
    echo ''$number_of_lines' lines'
}

function logtext() {
    ls -t log_*.txt | head -1 | xargs -I {} cat {} | grep $1 | less
}

function catexception()
{
    ls -t log_*.txt | head -1 | xargs -I {} cat {} | python ${ANDROID_DEV_SCRIPTS_DIR}/python/log/error_log_filter.py
}

function logexception()
{
    catexception | less
}

# Cat last logcat saved by dlog
alias getlog='ls -t log_*.txt | head -1'
alias catlog='ls -t log_*.txt | head -1 | xargs -I {} cat {}'
alias openlog='ls -t log_*.txt | head -1 | xargs -I {} sublime -n {}'
alias gilcat='adb logcat | grep GilLog'
alias gillog='ls -t log_*.txt | head -1 | xargs -I {} cat {} | grep "GilLog" | less'
alias clrcat='echo "Clearing logs from Android device "$(adb shell getprop ro.product.model) && adb logcat -c'
alias augcat='echo "Augment logcat buffer to 64M (Android device "$(adb shell getprop ro.product.model)")" && adb logcat -G 64M'

# Get info from connected device
alias droid-api='adb shell getprop ro.build.version.release'
alias droid-sdk='adb shell getprop ro.build.version.sdk'
alias droid-devicemodel='adb shell getprop ro.product.model'
alias droid-display-power-state='adb shell dumpsys power | grep "Display Power: state=" | cut -c22-'
alias droid-kernelversion='adb shell cat /proc/version'

alias droid-get-pkgname-from-pid='adb shell ps | grep '
alias droid-installed_apps="adb shell 'pm list packages -f' | sed -e 's/.*=//' | sort"

alias droid-get-focused-pkg="adb shell dumpsys activity activities | grep mFocusedActivity"

alias droid-force-stop-pkg="adb shell am force-stop "

alias droid-get-notifications="adb shell dumpsys notification | less"

alias droid-open-url='adb shell am start -a "android.intent.action.VIEW" -d '

alias droid-record-video-from-screen='video_dir=/sdcard/test.mp4 && echo "Saving video to "$video_dir && adb shell screenrecord $video_dir'

alias droid-list-all-installed-apks='adb shell dumpsys activity activities | grep apk | less'

alias droid-get-ipaddress-wlan='python2 '$ANDROID_DEV_SCRIPTS_DIR'/python/net/wlanip.py'

alias droid-get-processor-arch='adb shell getprop ro.product.cpu.abi'

function devdroid-connect-wifi()
{
    adb tcpip 5555
    adb connect $(droid-get-ipaddress-wlan)
}

function devdroid_sshtermux_into_device()
{
    if [ -z $1 ]; then
        ssh_port=7375
    else
        ssh_port=$1
    fi

    device_ip=$(python2 $ANDROID_DEV_SCRIPTS_DIR/python/net/wlanip.py)
    ssh $device_ip -p $ssh_port
}

function devdroid_usbsshtermux_into_device()
{
    if [ -z $1 ]; then
        ssh_port=7375
    else
        ssh_port=$1
    fi

    adb forward tcp:$ssh_port tcp:$ssh_port
    adb forward tcp:8080 tcp:8080
    ssh localhost -p $ssh_port
}

function uninstall_apk_with_packagename()
{
    installed_apps=$(adb shell 'pm list packages -f' | sed -e 's/.*=//' | sort)
    # echo 'Found APKs:'
    # # echo $(echo $installed_apps | grep $1)
    echo -n $installed_apps | grep $1 | xa adb uninstall {}
}

function droid-cpuinfo-pkg()
{
    pkg=$1
    adb shell dumpsys cpuinfo | grep $1
}

function droid-open-settings-pgk()
{
    pgk=$1
    adb shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$1
}

export ANDROID_LOCAL_PROPS_BKP_FILE="$HOME/workspace/scripts/android/android_local_properties/local.properties"

function devdroid_save_local_properties()
{
    echo 'Saving file '$1' as default local.properties'
    cp $1 $ANDROID_LOCAL_PROPS_BKP_FILE
}

function devdroid_write_local_properties()
{
    cp $ANDROID_LOCAL_PROPS_BKP_FILE $1
}

alias devdroid_show_all_local_properties='f "local.properties"'