#!/bin/bash
## This script captures new lines from the file music.html and appends them to music_daily.txt
cat /mnt/music.html | grep -v "Date" > /usr/local/music.html
inf="/usr/local/music.html"
tempf="/usr/local/music.temp"
outf="/usr/local/music_daily.txt"
DIFF=`diff $inf $tempf`
if [ "$DIFF" != "" ]; then
        egrep '<p>|Date' /mnt/music.html | iconv -c -f CP1251 -t UTF8 >> $outf
        cat $inf > $tempf
fi
