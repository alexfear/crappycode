#/bin/bash
#Author: Alex Antonov
#The program extracts every regular zip archive from the source directory,
#packs the data to a new password-encrypted RAR archive and then packs the archive again to a regular ZIP archive

SOURCE=/var/www/chemax/downloads/others
ENCRYPTED=/var/www/chemax/downloads/othersencrypted
TARGET=/var/www/chemax/downloads/othersprocessed
TEMP=/var/www/chemax/downloads/otherstemp
PASSWORD=qwertyqwerty #password for the archives
COUNTER=0
for FILE in $(ls $SOURCE); do
        /bin/echo $FILE | grep ".zip" >/dev/null 2>&1 || echo "$FILE is not a ZIP archive" >>/var/log/zypencrypt.log && continue
        FILERAR=`echo $FILE | sed -e 's/\.zip/\.rar/g'`
        /usr/bin/nice -n 5 /usr/bin/unzip -q $SOURCE/$FILE -d $TEMP || echo "$SOURCE/$FILE failed to unpack" >>/var/log/zypencrypt.log
        /usr/bin/nice -n 5 /usr/bin/rar a -ep -inul -hp$PASSWORD $ENCRYPTED/$FILERAR $TEMP/* || echo "$ENCRYPTED/$FILERAR failed to create" >>/var/log/zypencrypt.log
        /usr/bin/nice -n 5 /usr/bin/zip -jq $TARGET/$FILE $ENCRYPTED/$FILERAR || echo "$TARGET/$FILE failed to create" >>/var/log/zypencrypt.log
        /bin/rm -rf $TEMP/*
        /bin/rm -f $ENCRYPTED/$FILERAR
        ((++COUNTER));
done
/bin/echo "Number of processed files: $COUNTER" | tee /var/log/zypencrypt.log
