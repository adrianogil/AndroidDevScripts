########## ADD TO Your BASHRC ##### Android Dev Config Files ##########
# Useful alias for Android development
# export ANDROID_DEV_SCRIPTS_DIR=<PATH>
# source ${ANDROID_DEV_SCRIPTS_DIR}/bashrc.sh

source ${ANDROID_DEV_SCRIPTS_DIR}/android_dev.sh
source ${ANDROID_DEV_SCRIPTS_DIR}/vr_android_dev.sh

# @tool gt-sk
function droid-sk()
{
    droid_action=$(cat ${ANDROID_DEV_SCRIPTS_DIR}/*android*.sh | grep '# droidtool' | cut -c12- | sk)

    eval ${droid_action}
}
alias d="droid-sk"