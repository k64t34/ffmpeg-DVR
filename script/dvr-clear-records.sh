#!/bin/bash
#http://www.bash-scripting.ru/abs/chunks/pt02.html
echo Start  `date +"%a %d.%m.%Y %H:%M"`
StartDate=`date`
echo '***********************************************************'
echo 'IP cam records rotations         ver 0.1 by Skorik (c) 2015'
echo '***********************************************************'

config=$(dirname "$0")/'dvr-config.sh'

if [ ! -r "$config" ]; then
	echo Config file $config not found.
	exit 1
fi
source $config

#** Calculate disk Occupies
echo Folder $recFolder
echo Disk quota			$recDiskQuota GByte
DiskQuota=$[$recDiskQuota*1024*1024*1024]

if $(FileExists $recFolder $recPrefix*.mp4); then 
	File1080Size=`du -sb $recFolder/$recPrefix*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else	
	File1080Size=0
fi
echo -e "Files $recPrefix\t$(printf '%12u' $File1080Size) bytes $(HumanBytes $File1080Size)"


if $(FileExists $recFolder $FileMaskDecoder720*.mp4); then 
	File720Size=`du -s $recFolder/$FileMaskDecoder720*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else
	File720Size=0
fi	
echo -e "Files $FileMaskDecoder720\t$(printf '%12u' $File720Size) bytes $(HumanBytes $File720Size)"

if $(FileExists $recFolder $FileMaskDecoder576*.mp4); then 
	File576Size=`du -s $recFolder/$FileMaskDecoder576*.mp4 | awk '{s+=$1}END{printf "%.f", s}'`
else
	File576Size=0
fi	
echo -e "Files $FileMaskDecoder576\t$(printf '%12u' $File576Size) bytes $(HumanBytes $File576Size)"

FilesAll=$(($File1080Size+$File720Size+$File576Size))


echo -e "Disk quota\t$(printf '%12u \n' $DiskQuota)bytes $(HumanBytes $DiskQuota)"
echo -e "Occupies\t$(printf '%12u \n' $FilesAll)bytes $(HumanBytes $FilesAll)"

#
#** Delete old files
#
if (( $FilesAll > $DiskQuota )) ; then 
	if ((File576Size > 0));then
		echo -e "Overlimit\t$(printf '%12u \n' $(($FilesAll-DiskQuota)))bytes $(HumanBytes $(($FilesAll-DiskQuota)))"		
		echo "Delete old files $FileMaskDecoder576*.mp4"
		for i in `ls -1 -tr $recFolder/$FileMaskDecoder576*.mp4` ; do			
			FilesAll=$(( $FilesAll - `du -sb $i | awk '{print $1}'` ))
			echo ${i##*/}
			#mv $i ${i%.*}.bak
			unlink $i		
			if (( $FilesAll<$DiskQuota )) ; then
				break
			fi 
		done
	fi	
fi
if (( $FilesAll > $DiskQuota )) ; then 
	if ((File720Size > 0));then
		echo -e "Overlimit\t$(printf '%12u \n' $(($FilesAll-DiskQuota)))bytes $(HumanBytes $(($FilesAll-DiskQuota)))"
		echo "Delete old files $FileMaskDecoder720*.mp4"
		for i in `ls -1 -tr $recFolder/$FileMaskDecoder720*.mp4` ; do			
			FilesAll=$(($FilesAll - `du -sb $i | awk '{print $1}'`))
			echo ${i##*/}
			#mv $i ${i%.*}.bak		
			unlink $i		
			if (( $FilesAll<$DiskQuota )) ; then		
				break
			fi 
		done
	fi
fi

if (( $FilesAll > $DiskQuota )) ; then 
	if ((File1080Size > 0));then
		echo -e "Overlimit\t$(printf '%12u \n' $(($FilesAll-DiskQuota)))bytes $(HumanBytes $(($FilesAll-DiskQuota)))"
		echo "Delete old files $recPrefix*.mp4"
		for i in `ls -1 -tr $recFolder/$recPrefix*.mp4` ; do			
			FilesAll=$(( $FilesAll - `du -sb $i | awk '{print $1}'` ))
			echo ${i##*/}
			mv $i $arcFolder
			unlink $i			
			if (( $FilesAll<$DiskQuota )) ; then		
				break
			fi 
		done
	fi
fi
#
#** Transcode old files
#
echo "Transcode  $recPrefix*.mp4 older $DaySaveRec1080 days"
#ii=1
TranscodeDate=$(date --date='2 days ago' +%s)

for i in `ls -1 -tr $recFolder/$recPrefix*.mp4 2>/dev/nul` ; do
	newfile=${i##*/}	
	#echo $ii
	if (( $(date -r "$i" +%s)  >  $TranscodeDate ))  ;then
		break
	fi
	echo $newfile
	#echo ${newfile/$recPrefix/$FileMaskDecoder720}
	#/root/ffmpeg/
	#-hwaccel auto
	/root/ffmpeg/ffmpeg \
	-hwaccel auto \
	-loglevel quiet \
	-y \
	-an \
	-i $i \
	-r 25 \
	-s hd480 \
	-vcodec libx264 $recFolder/${newfile/$recPrefix/$FileMaskDecoder576}
#	echo errorlevel $?	
#	ii=$(($ii+1))
#	if (( $ii == 3 ));then	
#		break
#	fi	
	
	#-x264opts opencl \
	#-strict experimental
	#-t 15 \
	#-s hd720
	#-s hd480	
	# -r 25	
	#-vcodec libx264
	#-vcodec mpeg4 \
	#-f h264
	# -f mp4
	#-acodec copy
		
	unlink $i
done


#echo Decode $FileMaskDecoder720*.mp4 older 5 days
#for i in `ls -1 -tr $recFolder/$FileMaskDecoder720*.mp4 2>/dev/nul` ; do
#	echo $i	${i%%.*}	
	
	#ffmpeg -y -r 25 -i %i -vcodec mpeg4 -s 400x300 -f mp4 $recPrefix/$FileMaskDecoder720.mp4  
	#unlink $i
#done
echo StartDate $StartDate
echo Finish    `date +"%a %d.%m.%Y %H:%M"`

exit

ffmpeg -i rtsp://192.168.1.31:554/user=admin_password=RZYY1Y7i_channel=1_stream=0.sdp?real_stream \
    -y \
    -r 25 \
    -s hd1080 \
    -b 8192 \
    -t 910 \
    -vcodec copy \
    -metadata title="CAM1" \
    -f mp4  $BASEpath/cam01_1080_$(date +"%d.%m.%Y_%H-%M-%S").mp4



date +%s -r cam01_1080_26.11.2015_20-45-01.mp4













http://wiki.rsu.edu.ru/wiki/%D0%9F%D0%BE%D0%BB%D0%B5%D0%B7%D0%BD%D0%BE%D1%81%D1%82%D0%B8_%D0%B4%D0%BB%D1%8F_%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%D1%8E%D1%89%D0%B8%D1%85_%D0%B2_%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D0%BD%D0%BE%D0%B9_%D1%81%D1%82%D1%80%D0%BE%D0%BA%D0%B5_*nix#.D0.A0.D0.B0.D0.B7.D0.B1.D0.B8.D0.B2.D0.B0.D0.B5.D0.BC_.D0.BF.D0.B5.D1.80.D0.B5.D0.BC.D0.B5.D0.BD.D0.BD.D1.83.D1.8E_.D0.BD.D0.B0_.D0.B8.D0.BC.D1.8F_.D1.84.D0.B0.D0.B9.D0.BB.D0.B0_.D0.B8_.D1.80.D0.B0.D1.81.D1.88.D0.B8.D1.80.D0.B5.D0.BD.D0.B8.D0.B5
Разбиваем переменную на имя файла и расширение

Вариант 1 [2]:
~% FILE="example.tar.gz"
~% echo "${FILE%%.*}"
example
~% echo "${FILE%.*}"
example.tar
~% echo "${FILE#*.}"
tar.gz
~% echo "${FILE##*.}"
gz
Вариант 2:
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"
Вариант 3:
#!/bin/bash
for fullpath in "$@"
do
    filename="${fullpath##*/}"                      # Strip longest match of */ from start
    dir="${fullpath:0:${#fullpath} - ${#filename}}" # Substring from 0 thru pos of filename
    base="${filename%.[^.]*}"                       # Strip shortest match of . plus at least one non-dot char from end
    ext="${filename:${#base} + 1}"                  # Substring from len of base thru end
    if [[ -z "$base" && -n "$ext" ]]; then          # If we have an extension and no base, it's really the base
        base=".$ext"
        ext=""
    fi
 
    echo -e "$fullpath:\n\tdir  = \"$dir\"\n\tbase = \"$base\"\n\text  = \"$ext\""
done
Вариант 4:
basename filename .extension










	foo=$i
	path=${foo%/*}
	file=${foo##*/}
	base=${file%%.*}
	ext=${file#*.}
 bash  /media/629fe4c8-2336-41af-bdf6-0aaaceff7300/DVR/dvr-clear-records.sh
 
 
 ffmpeg loglevel
 const struct { const char *name; int level; } log_levels[] = {
        { "quiet"  , AV_LOG_QUIET   },
        { "panic"  , AV_LOG_PANIC   },
        { "fatal"  , AV_LOG_FATAL   },
        { "error"  , AV_LOG_ERROR   },
        { "warning", AV_LOG_WARNING },
        { "info"   , AV_LOG_INFO    },
        { "verbose", AV_LOG_VERBOSE },
        { "debug"  , AV_LOG_DEBUG   },
    };