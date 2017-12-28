export OSIG_FOLDER=$HOME/Downloads/OculusOsig/

function saveosig
{
    # Save specific osig to OSIG_FOLDER
    cp $1 $OSIG_FOLDER
}

function findosig
{
    if [ -z "$1" ]
    then
        target_directory='.'
    else
        target_directory=$1
    fi

    devicename=$(adb devices | tail -2 | head -1 | rev | cut -c8- | rev)

    cp $OSIG_FOLDER/oculussig_$devicename $target_directory
}
