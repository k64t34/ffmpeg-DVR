#!/bin/bash
#records folder
recFolder='/media/629fe4c8-2336-41af-bdf6-0aaaceff7300/DVR'
#recFolder='/media/465ab831-ca09-46b3-bb74-25b6b18a04fa/dvr/'
#disk quota in Gigabytes
recDiskQuota=100
#Filename mask for records
recPrefix=cam01_1080_
recPostfix='date +%Y%m%d%H%M'

#Filename mask for decoded records
FileMaskDecoder720=cam01_720_
FileMaskDecoder576=cam01_576_

#How maby days save records
DaySaveRec1080=3
DaySaveRec720=3

#ArchiveFolder
arcFolder='/media/dvr.arc'

if [ ! -d "$recFolder" ]; then
	echo Folder $recFolder not found.
	exit 1
fi
#***********************************************************
function FileExists() {
#***********************************************************
#http://stackoverflow.com/questions/6363441/check-if-a-file-exists-with-wildcard-in-shell-script
if test -n "$(find $1 -maxdepth 1 -name $2 -print -quit)"
then
    return 0
else
    return 1
fi
}
#***********************************************************
function HumanBytes() {
#***********************************************************
#http://www.linuxquestions.org/questions/linux-general-1/awk-to-convert-bytes-to-human-number-909214/
echo $1 | awk '{ split( "B KB MB GB TB" , v ); s=1; while( $1>=1024 ){ $1/=1024; s++ } print int($1)" "v[s] }'
}