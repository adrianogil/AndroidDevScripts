# droidtool droid-logcat: Custom logcat search
function droid-logcat()
{
    target_string=$1
    python3 -m droid.logcat.logcatobserver $1
}

# droidtool droid-cat: Show logcat
function droid-cat()
{
    target_device=$(droid-device)
    adb -s ${target_device} logcat
}

# droidtool droid-neko: Custom view of logcat
function droid-neko()
{
    target_device=$(droid-device)

    python3 $ANDROID_DEV_SCRIPTS_DIR/python/log/droidneko.py --device ${target_device}
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
        target_device=$(droid-device)

        device_model=$(adb -s ${target_device} shell getprop ro.product.model)
        device_time=$(adb -s ${target_device} shell date)
        echo "Device is $device_model"
        echo "Current device datetime is "$device_time
        log_file=log_${device_model}_$(date +%F-%H-%M)$log_sufix.txt
        echo 'Android log saved as '$log_file

        adb -s ${target_device} shell logcat -d -v time > $log_file
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