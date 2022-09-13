#!/bin/bash

dirMonitor="/usr/local/WowzaStreamingEngine/content"
dirStorage="/mnt/Videos/videoclips/Watch_Folder"
fileMonitorListLast=fileListLast.txt
fileMonitorListNow=fileListNow.txt
flagContinueMode=1
flagFileMoved=0
flagTimeDiff=300
flagCheckCnt=0
currentDT=$(date +%s)
tmpFileInfo=
tmpFileTime=
oldFileName=
oldFileSize=
oldFileTime=
oldFileChkCnt=
currentFileSize=
currentFileTime=
lineNumb=1
nowtime="date +'%Y-%m-%d %H:%M:%S'"


while [ "1" == $flagContinueMode ] ; do 
    if [ ! -f $fileMonitorListLast ]; then
        for entry in "$dirMonitor"/*
        do
            tmpFileInfo=$(ls -l $entry | awk '{print $5, $9}') 
            tmpFileTime=`stat -c '%Y' $entry` 
            echo "${tmpFileInfo} ${tmpFileTime} ${flagCheckCnt}" >> $fileMonitorListLast 
        done
    else
        while read line; do
            echo "$lineNumb : $line"
            IFS=' ' read -ra INFO <<< "$line"
            oldFileName="${INFO[1]}"
            oldFileSize="${INFO[0]}"
            oldFileTime="${INFO[2]}"
            oldFileChkCnt="${INFO[3]}"
            echo "name: ${oldFileName}, size: ${oldFileSize}, time: ${oldFileTime}, cnt: ${oldFileChkCnt} " 
            if [ -f $oldFileName ]; then
                currentFileSize=$(ls -l $oldFileName | awk '{print $5}') 
                currentFileTime=`stat -c '%Y' $oldFileName` 
                if [ "3" == $oldFileChkCnt ]; then
                    mv $oldFileName $dirStorage 
                    sed '/$line/d' $fileMonitorListLast 
                fi
                if [ $oldFileSize == $currentFileSize ]; then
                    sed '/$line/d' $fileMonitorListLast 
                    oldFileChkCnt=$((oldFileChkCnt+1))
                    echo "${oldFileSize} ${oldFileName} ${oldFileTime} ${oldFileChkCnt}" >> $fileMonitorListLast 
                else
                    sed '/$line/d' $fileMonitorListLast 
                    oldFileChkCnt=0
                    echo "${currentFileSize} ${oldFileName} ${oldFileTime} ${oldFileChkCnt}" >> $fileMonitorListLast 
                fi
            else
                sed '/$line/d' $fileMonitorListLast 
            fi
            
            lineNumb=$((lineNumb+1))
        done < $fileMonitorListLast
    fi

    sleep 60
done

exit 0
