#!/bin/bash
## This script gathers new lines from file Music.html to append them to music_daily.txt
cat /mnt/win/RadioLux/Music.html | grep -v "Date" > /usr/local/Music.html
inf="/usr/local/Music.html"
tempf="/usr/local/music.temp"
outf="/usr/local/music_daily.txt"
DIFF=`diff $inf $tempf`
if [ "$DIFF" != "" ]; then
        egrep '<p>|Date' /mnt/win/RadioLux/Music.html | iconv -c -f CP1251 -t UTF8 >> $outf
        cat $inf > $tempf
fi
exit 0
