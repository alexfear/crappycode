#!/bin/bash
## This script gets picture form videofile at a given second with help of ffmpeg library
time_stamp=`date +%F\ %T`
if [ "$1" != "" ] && [ "$2" != "" ]; then
    ffmpeg -i /usr/local/apache-tomcat/webapps/ROOT/$1 -vframes 1 -ss $2 -an -y -f mjpeg /usr/local/apache-tomcat/webapps/ROOT/$1.jpeg >/dev/null 2>/dev/null
else
    echo "$time_stamp: somthing's wrong in parameters! Path is: $1; Time is: $2" >> /var/log/get_video_skin.log
fi
exit 0
