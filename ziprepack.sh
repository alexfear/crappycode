#/bin/bash
#Author: Alex Antonov
#The program extracts every regular zip archive from the source directory,
#packs the data to a new password-encrypted RAR archive and then packs the archive again to a regular ZIP archive

SOURCE=/var/www/chemax/downloads/others
ENCRYPTED=/var/www/chemax/downloads/othersencrypted
TARGET=/var/www/chemax/downloads/othersprocessed
TEMP=/var/www/chemax/downloads/otherstemp
COUNTER=0
PASSWORD=qwertyqwerty

/bin/echo `date +%F" "%T`" -----------------------ziprepack started-------------------------" > /var/log/zipencrypt.log
for FILE in $(ls $SOURCE); do
        [[ "$FILE" == *.zip ]] || {
                echo "$FILE is not a ZIP archive" >>/var/log/zipencrypt.log
                continue
        }
        FILERAR=`echo $FILE | sed -e 's/\.zip/\.rar/g'`
        /usr/bin/nice -n 5 /usr/bin/unzip -q $SOURCE/$FILE -d $TEMP >>/var/log/zipencrypt.log 2>&1
        /usr/bin/nice -n 5 /usr/bin/rar a -ep -inul -hp$PASSWORD $ENCRYPTED/$FILERAR $TEMP/* >>/var/log/zipencrypt.log 2>&1
        /usr/bin/nice -n 5 /usr/bin/zip -jq $TARGET/$FILE $ENCRYPTED/$FILERAR >>/var/log/zipencrypt.log 2>&1
        /bin/rm -rf $TEMP/* >/dev/null 2>&1
        /bin/rm -rf $TEMP/.* >/dev/null 2>&1
        /bin/rm -f $ENCRYPTED/$FILERAR >/dev/null 2>&1
        ((++COUNTER))
done
/bin/echo "Number of processed files: $COUNTER" | tee -a /var/log/zipencrypt.log
