########## ADD TO Your BASHRC ##### Android Dev Config Files ##########
# Useful alias for Android development
# export ANDROID_DEV_SCRIPTS_DIR=<PATH>
# source ${ANDROID_DEV_SCRIPTS_DIR}/bashrc.sh

source ${ANDROID_DEV_SCRIPTS_DIR}/dev/android_dev.sh
source ${ANDROID_DEV_SCRIPTS_DIR}/dev/vr_android_dev.sh
source ${ANDROID_DEV_SCRIPTS_DIR}/dev/logs.sh


if [ -z "$DROID_PYTHON_PATH" ]
then
    export DROID_PYTHON_PATH=$ANDROID_DEV_SCRIPTS_DIR/python
    export PYTHONPATH=$DROID_PYTHON_PATH:$PYTHONPATH
fi

# @tool droid-fz
function droid-fz()
{
    droid_action=$(cat ${ANDROID_DEV_SCRIPTS_DIR}/dev/*android*.sh | grep '# droidtool' | cut -c12- | sk)

    eval ${droid_action}
}
alias d="droid-fz"
