#!/bin/bash
echo "["`date +"%Y-%m-%d %H:%M:%S"`"]" >> /var/log/clipclear.log

BeforeFileCount=$(ls -l /usr/local/WowzaStreamingEngine/content |grep "^-"| wc -l)

rm -rf /usr/local/WowzaStreamingEngine/content/20*.mp4 &> /dev/null

AfterFileCount=$(ls -l /usr/local/WowzaStreamingEngine/content |grep "^-"| wc -l)

echo "BeforeFileCount:${BeforeFileCount}, AfterFileCount:${AfterFileCount} " >> /var/log/clipclear.log
