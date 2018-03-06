#/bin/bash
#Author: Alex Antonov
#The program extracts every regular zip archive from the source directory,
#packs the data to a new password-protected RAR archive and then packs the archive again to a regular ZIP archive

SOURCE=
TARGET=
TEMP=
COUNTER=0
PASSWORD=qwertyqwerty

clear_temp () {
        /bin/rm -rf $TEMP/* >/dev/null 2>&1
        /bin/rm -rf $TEMP/.* >/dev/null 2>&1
}

/bin/echo `date +%F" "%T`" -----------------------ziprepack started-------------------------" >> /var/log/ziprepack.log
for FILE in $(ls $SOURCE); do
        [[ "$FILE" == *.zip ]] || continue
        FILERAR=`echo $FILE | sed -e 's/\.zip/\.rar/g'`
        /usr/bin/nice -n 5 /usr/bin/unzip -q $SOURCE/$FILE -d $TEMP >/dev/null 2>&1 || {
                echo "$SOURCE/$FILE has issues with extraction. Skipping..." >>/var/log/ziprepack.log
                clear_temp
                continue
        }
        /usr/bin/nice -n 5 /usr/bin/rar a -ep1 -inul -hp$PASSWORD $TEMP/$FILERAR $TEMP/* >/dev/null 2>&1 || {
                echo "$TEMP/$FILERAR has not been archived properly. Skipping..." >>/var/log/ziprepack.log
                clear_temp
                continue
        }
        /usr/bin/nice -n 5 /usr/bin/zip -jq $TARGET/$FILE $TEMP/$FILERAR >/dev/null 2>&1 || echo "$TARGET/$FILE has not been archived properly" >>/var/log/ziprepack.log
        clear_temp
        ((++COUNTER))
done
/bin/echo `date +%F" "%T`" Number of processed files: $COUNTER--------------------------------------------" | tee -a /var/log/ziprepack.log
