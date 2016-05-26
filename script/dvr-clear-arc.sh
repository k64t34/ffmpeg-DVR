#!/bin/bash
#http://www.bash-scripting.ru/abs/chunks/pt02.html
echo Start  `date +"%a %d.%m.%Y %H:%M"`
StartDate=`date`
echo '***********************************************************'
echo 'IP cam archive clear             ver 0.2 by Skorik (c) 2016'
echo '***********************************************************'

config=$(dirname "$0")/'dvr-config.sh'

if [ ! -r "$config" ]; then
	echo Config file $config not found.
	exit 1
fi
source $config

#** Calculate disk Occupies
echo Folder $arcFolder
echo Disk quota			$recDiskQuota GByte
DiskQuota=$[$recDiskQuota*1024*1024*1024]

if $(FileExists $arcFolder $recPrefix*.mp4); then 
	File1080Size=`du -sb $arcFolder/$recPrefix*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else	
	File1080Size=0
fi
echo -e "Files $recPrefix\t$(printf '%12u' $File1080Size) bytes $(HumanBytes $File1080Size)"


if $(FileExists $arcFolder $FileMaskDecoder720*.mp4); then 
	File720Size=`du -s $arcFolder/$FileMaskDecoder720*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else
	File720Size=0
fi	
echo -e "Files $FileMaskDecoder720\t$(printf '%12u' $File720Size) bytes $(HumanBytes $File720Size)"

if $(FileExists $arcFolder $FileMaskDecoder576*.mp4); then 
	File576Size=`du -s $arcFolder/$FileMaskDecoder576*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else
	File576Size=0
fi	
echo -e "Files $FileMaskDecoder576\t$(printf '%12u' $File576Size) bytes $(HumanBytes $File576Size)"

FilesAll=$(($File1080Size+$File720Size+$File576Size))

DiskFreeinarcFolder=$(DiskFree $arcFolder)

echo -e "Disk quota\t$(printf '%12u \n' $DiskQuota)bytes $(HumanBytes $DiskQuota)"
echo -e "Occupies\t$(printf '%12u \n' $FilesAll)bytes $(HumanBytes $FilesAll)"
echo -e "Disk Free\t$(printf '%12u \n' $DiskFreeinarcFolder)bytes $(HumanBytes $DiskFreeinarcFolder)"
echo -e "Keep Free\t$(printf '%12u \n' $bKeepFreeDisk)bytes $(HumanBytes $bKeepFreeDisk)"

if (( $FilesAll > $DiskQuota )) || ((DiskFreeinarcFolder < $((KeepFreeDisk*1024*1024*1024)))) ; then 
	if ((File1080Size > 0));then
		echo -e "Overlimit\t$(printf '%12u \n' $(($FilesAll-DiskQuota)))bytes $(HumanBytes $(($FilesAll-DiskQuota)))"
		echo "Delete old files $recPrefix*.mp4"
		for i in `ls -1 -tr $arcFolder/$recPrefix*.mp4` ; do			
			FilesAll=$(( $FilesAll - `du -sb $i | awk '{print $1}'` ))
			echo ${i##*/}
			echo  Delete $i 
			unlink $i			
			if (( $FilesAll<$DiskQuota )) && ((DiskFreeinarcFolder > $((KeepFreeDisk*1024*1024*1024)))) ; then		
				break
			fi 
		done
	fi
fi

echo StartDate $StartDate
echo Finish    `date +"%a %d.%m.%Y %H:%M"`
exit
