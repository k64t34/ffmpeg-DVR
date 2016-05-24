#!/bin/bash
echo Start  `date +"%a %d.%m.%Y %H:%M"`
StartDate=`date`
echo '***********************************************************'
echo 'IP cam records                   ver 0.2 by Skorik (c) 2016'
echo '***********************************************************'

config=$(dirname "$0")/'dvr-config.sh'

if [ ! -r "$config" ]; then
	echo Config file $config not found.
	exit 1
fi
source $config

DiskFreeinRecFolder=$(DiskFree $recFolder)
echo -e "DiskFree $DiskFreeinRecFolder bytes $(HumanBytes $DiskFreeinRecFolder)"
if [ "$DiskFreeinRecFolder"  -lt "$((KeepFreeDisk*1024*1024*1024))" ]; then
	echo "Too small free space for record. Need at least $KeepFreeDisk GB"
else
ffmpeg -i rtsp://192.168.1.31:554/user=admin_password=RZYY1Y7i_channel=1_stream=0.sdp?real_stream \
    -y \
    -r 25 \
    -s hd1080 \
    -b 8192 \
    -t 910 \
    -vcodec copy \
    -metadata title="CAM1" \
    -f mp4 \
	$recFolder/$recPrefix$(eval $recPostfix).mp4
	

echo Finish  `date +"%A %d.%m.%Y %H:%M"`
fi
exit
