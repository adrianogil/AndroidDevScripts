
target_file=$1 # File that will store all URL from mobile
adb forward tcp:9222 localabstract:chrome_devtools_remote
wget -O tabs.json http://localhost:9222/json/list

cat tabs.json | grep 'url' | tr ',' ' ' |  awk '{print $2}' > $target_file
rm tabs.json
session_size=$(cat $target_file | wc -l)
echo 'Saved'$session_size' open tabs from Android Google Chrome into file '$target_file