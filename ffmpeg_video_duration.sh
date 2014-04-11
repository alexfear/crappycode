#!/bin/bash
## This script gets videofile duration (format: hh:mm:ss) with help of ffmpeg library
time_stamp=`date +%F\ %T`
if [ "$1" != "" ]; then
        ffmpeg -i "/mnt/data/web/lux/$1" 2>&1 | grep "Duration" | cut -d " " -f 4 - | sed s/....$//
else
    echo "$time_stamp: Somthing's wrong in parameter! Value is: /mnt/data/web/lux/$1" >> /var/log/get_video_duration.log
fi
exit 0
