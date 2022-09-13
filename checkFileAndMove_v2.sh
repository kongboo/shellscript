#!/bin/bash

dirMonitor="/usr/local/WowzaStreamingEngine/content"
dirStorage="/mnt/Videos/videoclips/Watch_Folder"
logFile="var/log/checkFileAndMove.log"
NowTime=
fileMonitorListLast=fileListLast.txt
fileMonitorListNow=fileListNow.txt
fileMonitorListLastSize=
flagContinueMode=1
flagFileMoved=0
flagTimeDiff=300
flagCheckCnt=0
currentDT=$(date +%s)
tmpFileInfo=
tmpFileName=
tmpFileTime=
tmpFileTmp=
tmpFileShortName=
oldFileSize=
oldFileName=
oldFileShortName=
oldFileTime=
oldFileChkCnt=
currentFileSize=
currentFileTime=
lineNumb=1


while [ "1" == $flagContinueMode ] ; do 
    fileMonitorListLastSize=$(ls -l $fileMonitorListLast | awk '{print $5}')
    if [ ! -f $fileMonitorListLast ]; then
        for entry in "$dirMonitor"/*
        do
            #檔案大小
            tmpFileInfo=$(ls -l $entry | awk '{print $5}')
            #檔案時間 
            tmpFileTime=`stat -c '%Y' $entry`
            #檔案完整路徑
            tmpFileName=$(ls -l $entry | awk '{print $9}')
            #檔案名稱
            tmpFileShortName=$(basename "$tmpFileName") 
            #取tmp檔
            tmpFileTmp=$(ls -l $entry | grep '.tmp')
            #取現在時間
            NowTime=`date +"%Y-%m-%d %H:%M:%S"`
            #將不是tmp檔的檔案不寫入fileMonitorListLast  
            if [ "$tmpFileTmp" == "" ] && [ -f $entry ]; then
                echo "${tmpFileInfo} ${tmpFileName} ${tmpFileShortName} ${tmpFileTime} ${flagCheckCnt}" >> $fileMonitorListLast 
                echo "Time:${NowTime} Name:${tmpFileShortName} 寫入 ${fileMonitorListLast}" >> $logFile
            fi
        done
    else
        #刪除空白的fileMonitorListLast
        if [ ! -s $fileMonitorListLast ]; then
            rm -rf $fileMonitorListLast
        fi        
        while read line; do
            echo "$lineNumb : $line"        
            #讀fileMonitorListLast內容
            IFS=' ' read -ra INFO <<< "$line"
            #取INFO內的對應值
            oldFileSize="${INFO[0]}"
            oldFileName="${INFO[1]}"
            oldFileShortName="${INFO[2]}"
            oldFileTime="${INFO[3]}"
            oldFileChkCnt="${INFO[4]}"
            echo "name: ${oldFileName}, size: ${oldFileSize}, time: ${oldFileTime}, cnt: ${oldFileChkCnt} " 
            #檢查紀錄中檔案是否還在目錄區
            if [ -f $oldFileName ]; then
                #檢查目前檔案的大小與時間
                currentFileSize=$(ls -l $oldFileName | awk '{print $5}') 
                currentFileTime=`stat -c '%Y' $oldFileName` 
                NowTime=`date +"%Y-%m-%d %H:%M:%S"`
                #若oldFileChkCnt=3，將檔案搬至dirStorage目錄區，刪除該行紀錄
                if [ "3" == $oldFileChkCnt ]; then
                    mv $oldFileName $dirStorage
                    echo "Time:${NowTime} Name:${oldFileShortName} mv至 ${dirStorage}" >> $logFile  
                    sed -i "/$oldFileShortName/d" $fileMonitorListLast
                fi
                #若目前檔案大小與之前紀錄一樣，刪除該行紀錄，oldFileChkCnt+1，並寫入
                if [ $oldFileSize == $currentFileSize ]; then
                    sed -i "/$oldFileShortName/d" $fileMonitorListLast 
                    oldFileChkCnt=$((oldFileChkCnt+1))
                    echo "${oldFileSize} ${oldFileName} ${oldFileShortName} ${oldFileTime} ${oldFileChkCnt}" >> $fileMonitorListLast 
                #若目前檔案大小與之前紀錄不一樣，刪除該行紀錄，oldFileChkCnt+1，並寫入
                else
                    sed -i "/$oldFileShortName/d" $fileMonitorListLast
                    oldFileChkCnt=0
                    echo "${currentFileSize} ${oldFileName} ${oldFileShortName} ${oldFileTime} ${oldFileChkCnt}" >> $fileMonitorListLast 
                fi
            #若不在，將紀錄刪除
            else
                sed -i "/$oldFileShortName/d" $fileMonitorListLast
            fi
            lineNumb=$((lineNumb+1))
            sleep 3
        done < $fileMonitorListLast
    fi
    sleep 60s
done
exit 0
