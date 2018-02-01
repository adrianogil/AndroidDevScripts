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

function get_package_name_from_apk()
{
     $ANDROID_SDK/build-tools/26.0.2/aapt dump badging $1 | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g
}

# Uninstall android app
function u()
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

# Get info from connected device
alias droid-api='adb shell getprop ro.build.version.release'
alias droid-sdk='adb shell getprop ro.build.version.sdk'
alias droid-devicemodel='adb shell getprop ro.product.model'
alias droid-displaystate='adb shell dumpsys power | grep "Display Power: state=" | cut -c22-'
alias droid-kernelversion='adb shell cat /proc/version'

alias droid-get-pkgname-from-pid='adb shell ps | grep '
alias droid-installed_apps="adb shell 'pm list packages -f' | sed -e 's/.*=//' | sort"

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