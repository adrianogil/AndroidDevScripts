
alias droid-bkp-apks='python2 $ANDROID_DEV_SCRIPTS_DIR/python/apks/backup_apks.py'

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
    if [ -z $1 ]; then
        if hash gfind 2>/dev/null; then
            # gfind cab be installed by "brew install findutils"
            apk_file=$(gfind . -name '*.apk' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort | awk '{print $9}' | tail -1)
        else
            apk_file=$(find . -name '*.apk' | head -1)
        fi
    else
        apk_file=$1
    fi
    device_model=$(adb shell getprop ro.product.model)
    echo "Installing APK "$apk_file" in device "$device_model
    apk_date=$(date -r $apk_file)
    package_name=$(get_package_name_from_apk $apk_file)
    echo " -> package name: "$package_name
    echo " -> build size: "$(du -sh $apk_file | awk '{print $1}')
    echo " -> build time: "$apk_date
    if [ -z ${ANDROID_IKC_LAST_BUILD_TIME+x} ]; then
        echo ""
    else
        echo "Last build time was "$ANDROID_IKC_LAST_BUILD_TIME
    fi
    export ANDROID_IKC_LAST_BUILD_TIME=$apk_date
    python2 ${ANDROID_DEV_SCRIPTS_DIR}/python/apks/smart_install.py ${package_name} $(abspath $apk_file)
    # adb install -r $apk_file
    echo "Clear logcat"
    adb logcat -c
    echo "Augment logcat buffer to 64MB"
    adb logcat -G 64M
    echo "Launch Activity from APK "$apk_file
    launch_from_apk $apk_file

}

function droid-apk-info()
{
    aapt_tool=$(find $ANDROID_SDK/ -name 'aapt' | tail -1)
    $aapt_tool dump badging $1
}


function apk_permissions()
{
    if [ -z $1 ]; then
        if hash gfind 2>/dev/null; then
            # gfind cab be installed by "brew install findutils"
            apk_file=$(gfind . -name '*.apk' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort | awk '{print $9}' | tail -1)
        else
            apk_file=$(find . -name '*.apk' | head -1)
        fi
    else
        apk_file=$1
    fi

    aapt_tool=$(find $ANDROID_SDK/ -name 'aapt' | tail -1)
    $aapt_tool d permissions $apk_file
}



function get_package_name_from_apk()
{
    aapt_tool=$(find $ANDROID_SDK/ -name 'aapt' | tail -1)
    $aapt_tool dump badging $1 | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'//g
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
alias droid-apk-launch="launch_from_apk"

# Launch Application from package name
function launch_package()
{
    adb shell monkey -p $1 -c android.intent.category.LAUNCHER 1
}

function droid-launch-app()
{
    APK=$1
    ACTIVITY=$2

    adb shell am start -n ${APK}/${ACTIVITY}
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

    if [[ $0 == *termux* ]]; then
        device_model=$(getprop ro.product.model)
        device_time=$(date)
        echo "Device is $device_model"
        echo "Current device datetime is "$device_time
        log_file=log_${device_model}_$(date +%F-%H-%M)$log_sufix.txt
        echo 'Android log saved as '$log_file
        logcat -d -v time > $log_file
    else
        device_model=$(adb shell getprop ro.product.model)
        device_time=$(adb shell date)
        echo "Device is $device_model"
        echo "Current device datetime is "$device_time
        log_file=log_${device_model}_$(date +%F-%H-%M)$log_sufix.txt
        echo 'Android log saved as '$log_file

        adb shell logcat -d -v time > $log_file
    fi

    number_of_lines=$(cat $log_file | wc -l)
    echo ''$number_of_lines' lines'
}

function catlog() {
    if [ -z $2 ]; then
        log_file=$(ls -t log_*.txt | head -1)
    else
        log_file=$(ls -t log_*.txt | grep $2 | head -1)
    fi

    cat $log_file
}

function logtext() {
    if [ -z $2 ]; then
        log_file=$(ls -t log_*.txt | head -1)
    else
        log_file=$(ls -t log_*.txt | grep $2 | head -1)
    fi

    cat $log_file | grep $1 | less
}

function catexception()
{
    ls -t log_*.txt | head -1 | xargs -I {} cat {} | python ${ANDROID_DEV_SCRIPTS_DIR}/python/log/error_log_filter.py
}


function logunitypid()
{
    log_path=$(ls -t log_*.txt | head -1)
    python ${ANDROID_DEV_SCRIPTS_DIR}/python/log/logunitypid.py "$PWD/$log_path"
}

function catunity()
{
    unitypid=$(logunitypid)

    catlog | grep $unitypid
}

function logunity()
{
    unitypid=$(logunitypid)

    logtext $unitypid
}

function logunityexception()
{
    unitypid=$(logunitypid)

    catexception | grep $unitypid | less
}

function logexception()
{
    catexception | less
}

# Cat last logcat saved by dlog
alias getlog='ls -t log_*.txt | head -1'
alias openlog='ls -t log_*.txt | head -1 | xargs -I {} sublime -n {}'
alias gilcat='adb logcat | grep GilLog'
alias gillog='ls -t log_*.txt | head -1 | xargs -I {} cat {} | grep "GilLog" | less'

function clrcat()
{
    if [[ $0 == *termux* ]]; then
        echo "Clearing logs from Android device "$(getprop ro.product.model)
        logcat -c
    else
        echo "Clearing logs from Android device "$(adb shell getprop ro.product.model)
        adb logcat -c
    fi
}

function augcat()
{
    if [[ $0 == *termux* ]]; then
        echo "Augment logcat buffer to 64M (Android device "$(getprop ro.product.model)")"
        logcat -G 64M
    else
        echo "Augment logcat buffer to 64M (Android device "$(adb shell getprop ro.product.model)")"
        adb logcat -G 64M
    fi
}

function apks()
{
    if [[ $1 == "-d" ]]; then
        gfind . -name '*.apk' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort -r | awk '{print $9"\t"$1}'
    else
        find . -name "*.apk"
    fi

}

function aars()
{
    if [[ $1 == "-d" ]]; then
        gfind . -name '*.aar' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort -r | awk '{print $9"\t"$1}'
    else
        find . -name "*.aar"
    fi
}

# droidtool droid
# @tool droid - List Android devices
function droid()
{
    adb devices
}

# droidtool droid-device
# @tool droid-device - Pick an available Android device
function droid-device()
{
    if [[ $(adb devices | wc -l) -le 3 ]]; then
        selected_device=$(adb devices | tail -n +2 | awk '{print $1}')
    else
        selected_device=$(adb devices | tail -n +2 | awk '{print $1}' | sk)
    fi
    echo ${selected_device} | tr '\n' ' ' | pbcopy
    echo ${selected_device}
}

# droidtool droid-cat
# @tool droid-cat - Show logcat
function droid-cat()
{
    target_device=$(droid-device)
    adb -s ${target_device} logcat
}

# droidtool droid-scrcpy
# @tool droid-scrcpy - Open a scrcpy instance with an available Android device
function droid-scrcpy()
{
    target_device=$(droid-device)
    scrcpy -s ${target_device}
}

function droid-playstore-install()
{
    package=$1
    adb shell am start -a 'android.intent.action.VIEW' -d 'market://details?id='$package
}

alias droid-apk-install='adb install'
alias droid-app-clear-data='adb shell pm clear'
alias droid-app-path='adb shell pm path'

# Get info from connected device
alias droid-api='adb shell getprop ro.build.version.release'
alias droid-sdk='adb shell getprop ro.build.version.sdk'
alias droid-devicemodel='adb shell getprop ro.product.model'
alias droid-display-power-state='adb shell dumpsys power | grep "Display Power: state=" | cut -c22-'
alias droid-battery-level='adb shell dumpsys battery | grep level'
alias droid-kernelversion='adb shell cat /proc/version'

alias droid-screen-size='adb shell wm size'
alias droid-screen-dpi='adb shell wm density'

alias droid-pkgname-from-pid='adb shell ps | grep '
alias droid-installed_apps="adb shell 'pm list packages -f' | sed -e 's/.*=//' | sort"

alias droid-focused-pkg="adb shell dumpsys activity activities | grep mFocusedActivity"

alias droid-force-stop-pkg="adb shell am force-stop "

alias droid-get-notifications="adb shell dumpsys notification | less"

alias droid-open-url='adb shell am start -a "android.intent.action.VIEW" -d '
alias dou="echo 'Open URL on Android device' && droid-open-url"

alias droid-record-video-from-screen='video_dir=/sdcard/test.mp4 && echo "Saving video to "$video_dir && adb shell screenrecord $video_dir'

alias droid-get-ipaddress-wlan='python2 '$ANDROID_DEV_SCRIPTS_DIR'/python/net/wlanip.py'

alias droid-get-processor-arch='adb shell getprop ro.product.cpu.abi'

alias droid-get-gpu-info='adb shell dumpsys | grep GLES'

# From https://github.com/ender503/Awesome-ADB-toolkits/blob/master/environment
alias droid-home="adb shell am start -c android.intent.category.HOME -a android.intent.action.MAIN"
alias droid-settings="adb shell am start -a android.settings.SETTINGS"
alias droid-developer-options="adb shell am start -n com.android.settings/.DevelopmentSettings"

alias droid-keyevent-back="adb shell input keyevent 4"
alias droid-keyevent-home="adb shell input keyevent 3"
alias droid-keyevent-screen-turnoff="adb shell input keyevent 26"
alias droid-keyevent-camera="adb shell input keyevent 27"
alias droid-keyevent-play="adb shell input keyevent 126"
alias droid-keyevent-pause="adb shell input keyevent 127"

alias droid-time="adb shell date"

alias droid-get-free-ram="adb shell dumpsys meminfo | grep \"Free RAM\""

alias droid-dumpsys-services="adb shell dumpsys activity services"
alias droid-dumpsys-pkg="adb shell dumpsys package"

alias droid-filesystem="adb shell df -h"

alias droid-volume-up="adb shell input keyevent 24"
alias droid-volume-down="adb shell input keyevent 25"

alias droid-brightness-get="adb shell settings get system screen_brightness"
alias droid-brightness-set="adb shell settings put system screen_brightness"

function droid-app-activities()
{
    # Using command from
    # https://stackoverflow.com/questions/33441138/how-to-find-out-activity-names-in-a-package-android-adb-shell
    package_name=$1
    adb shell dumpsys package | grep -i "$package_name" | grep Activity
}

function droid-open()
{
    file=$1

    if [ ${file: -4} == ".pdf" ]; then
        droid-open-pdf $file
    elif [ ${file: -4} == ".stl" ]; then
        droid-open-model $file
    elif [ ${file: -4} == ".txt" ]; then
        droid-open-text $file
    else
        droid-open-file $file
    fi
}

alias dp="droid-open"

function droid-open-text()
{
    echo "Open text file "$1"using DroidEdit Free"

    if [[ $0 == *termux* ]]; then
        real_file_path=$(abspath $1)
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        am start -n "$TEXT_EDITOR_APP" -d "file://"$real_file_path
    else
        real_file_path=$1
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        adb shell am start -n "$TEXT_EDITOR_APP" -d "file://"$real_file_path
    fi
}

function droid-open-text-as-tmp()
{
    file=$1

    echo "Open text file "$file" in a tmp folder using DroidEdit Free"

    filename=$(basename -- "$file")
    file_dir="${file%$filename}"

    tmp_path=/sdcard/tmp/tmp_$filename

    cp $file $tmp_path

    echo $tmp_path > $file.tmp
    text_file=$tmp_path

    if [[ $0 == *termux* ]]; then
        real_file_path=$(abspath $text_file)
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        am start -n "$TEXT_EDITOR_APP" -d "file://"$real_file_path
    else
        real_file_path=$text_file
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        adb shell am start -n "$TEXT_EDITOR_APP" -d "file://"$real_file_path
    fi
}
alias dp-txt='droid-open-text-as-tmp'

function droid-reload-text-from-tmp()
{
    file=$1
    tmp_file=$(cat $file.tmp)
    mv $tmp_file $file
    rm $file.tmp
}
alias dp-txt-reload='droid-reload-text-from-tmp'

# Based on https://android.stackexchange.com/a/199496
function droid-get-open-chrome-tabs()
{
    if [ -z "$1" ]
    then
        session_file=$(gfind . -name '*.chrome-session' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort -r | awk '{print $9}' | head -1)
    else
        session_file=$1'.chrome-session'
    fi
    adb forward tcp:9222 localabstract:chrome_devtools_remote
    wget -O $TMP_DIR/tabs.json http://localhost:9222/json/list

    cat $TMP_DIR/tabs.json | grep 'url' | tr ',' ' ' |  awk '{print $2}' > $session_file
    session_size=$(cat $session_file | wc -l)
    echo 'Saved'$session_size' open tabs from Android Google Chrome into file '$session_file
}

function droid-open-file()
{
    echo "Open file "$1

    if [[ $0 == *termux* ]]; then
        real_file_path=$(abspath $1)
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        am start -a android.intent.action.VIEW -d  "file://"$real_file_path
    else
        real_file_path=$1
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        adb shell am start -a android.intent.action.VIEW -d  "file://"$real_file_path
    fi
}

function droid-open-model()
{
    echo "Open text file "$1"using ModelViewer"

    if [[ $0 == *termux* ]]; then
        real_file_path=$(abspath $1)
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        am start -n "com.dmitrybrant.modelviewer/.MainActivity" -d "file://"$real_file_path
    else
        real_file_path=$1
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        adb shell am start -n "com.dmitrybrant.modelviewer/.MainActivity" -d "file://"$real_file_path
    fi
}


function droid-open-pdf()
{
    echo "Open file "$1

    if [[ $0 == *termux* ]]; then
        real_file_path=$(abspath $1)
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        am start -a android.intent.action.VIEW -d  "file://"$real_file_path -t "application/pdf"
    else
        real_file_path=$1
        real_file_path=$(echo $real_file_path | sed "s@data/data/com.termux/files/home/storage/shared@sdcard@g" )

        adb shell am start -a android.intent.action.VIEW -d  "file://"$real_file_path -t "application/pdf"
    fi
}

function droid-app-version()
{
    if [ -z $1 ]; then
        if hash gfind 2>/dev/null; then
            # gfind cab be installed by "brew install findutils"
            apk_file=$(gfind . -name '*.apk' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort | awk '{print $9}' | tail -1)
        else
            apk_file=$(find . -name '*.apk' | head -1)
        fi

        package_name=$(get_package_name_from_apk $apk_file)
    else
        package_name=$1
    fi

    adb shell dumpsys package $package_name | grep versionName | cut -c17-
}

function droid-list-all-installed-apks()
{
    if [ -z $1 ]; then
        target_device=$(droid-device)
    else
        target_device=$1
    fi

    adb -s ${target_device} shell pm list packages -f | sed "s/apk=/ /" | awk '{print $2}'
}

function droid-list-all-installed-apks-sk()
{
    if [ -z $1 ]; then
        target_device=$(droid-device)
    else
        target_device=$1
    fi

    adb -s ${target_device} shell pm list packages -f | sed "s/apk=/ /" | awk '{print $2}' | sk
}

function droid-app()
{
    if [ -z $1 ]; then
        if hash gfind 2>/dev/null; then
            # gfind cab be installed by "brew install findutils"
            apk_file=$(gfind . -name '*.apk' -type f -printf "%-.22T+ %M %n %-8u %-8g %8s %Tx %.8TX %p\n" | sort | awk '{print $9}' | tail -1)
        else
            apk_file=$(find . -name '*.apk' | head -1)
        fi

        echo "Got package name from APK "$apk_file

        package_name=$(get_package_name_from_apk $apk_file)
    else
        package_name=$1
    fi

    echo "Package name: "$package_name
    echo "Package version: "$(droid-app-version $package_name)
}

function droid-app-add-permission()
{
    app_package=$1
    permission=$2
    adb shell pm grant $app_package $permission
}

function droid-app-install-time()
{
    adb shell dumpsys package $1  | grep -A1 "firstInstallTime"
}

function droid-app-list-permissions()
{
    if [ -z $2 ]; then
        target_device=$(droid-device)
    else
        target_device=$2
    fi

    if [ -z $1 ]; then
        package_name=$(droid-list-all-installed-apks-sk ${target_device})
    else
        package_name=$1
    fi

    echo ${target_device}
    echo ${package_name}

    adb -s ${target_device} shell dumpsys package ${package_name} | grep "granted="
}

function droid-device-info()
{
    device_model=$(adb shell getprop ro.product.model)
    device_version=$(adb shell getprop ro.bootloader)
    kernel_version=$(droid-kernelversion)
    droid_api=$(adb shell getprop ro.build.version.release)
    droid_sdk=$(adb shell getprop ro.build.version.sdk)

    echo "Current device is a "$device_model
    echo "Device version: "${device_version}
    echo "Android API: "$droid_api" and Android SDK "$droid_sdk
    echo "Kernel version: "$kernel_version
}

function droid-recents-tasks()
{
    if [[ $0 == *termux* ]]; then
        dumpsys activity | grep ": TaskRecord{"
    else
        adb shell dumpsys activity | grep ": TaskRecord{"
    fi
}

# Take a look at http://www.twisterrob.net/blog/2015/04/android-full-thread-dump.html
function droid-kill()
{
    pkg_name=$1

    adb shell am force-stop $pkg_name
    adb shell am kill --user all $pkg_name
}

function devdroid_list_libdependencies()
{
     $ANDROID_SDK/ndk-bundle/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-readelf -d $1 | grep "\(NEEDED\)"
}

function droid-get-anr-traces()
{
    if [ -z $1 ]; then
        log_sufix=""
    else
        log_sufix="_"$1
    fi

    trace_log_file="traces${log_sufix}_$(adb shell getprop ro.product.model)_$(date +%F-%H-%M).txt"

    adb pull /data/anr/traces.txt $trace_log_file

    # If it fails you should do
    # adb shell "cat /data/anr/traces.txt" > traces.txt
}

function droid-get-screenshot()
{
    adb shell screencap -p /sdcard/screen.png
    adb pull /sdcard/screen.png
    adb shell rm /sdcard/screen.png
    mv screen.png screenshot_$(date +%F_%H_%M).png
}

function droid-get-ui-xml()
{
    if [ -z $1 ]; then
        target_file="ui"
    else
        target_file=$1
    fi

    adb exec-out uiautomator dump /dev/tty > ${target_file}.xml

    echo "Downloaded UI XML into file '"${target_file}".xml'"
}

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

function devdroid_keystore_info()
{
    if [ -z $1 ]; then
        keystore_file=$(find . -name '*.keystore' | head -1 | rev | cut -c1- | rev )
        echo "Found keystore "$keystore_file

        keytool -v -list -keystore "$keystore_file"
    else
        if [ -z $2 ]; then
            keytool -list -keystore $1 -alias $2
        else
            keytool -v -list -keystore $1
        fi
    fi

    keytool -list -keystore .keystore -alias foo
}

alias devdroid_show_all_local_properties='f "local.properties"'

function kill-all-adb-instances()
{
    ps aux | grep "adb -L" |  grep -v "grep" | awk '{print $2}' | xargs -I {} sudo kill -9 {}
}
