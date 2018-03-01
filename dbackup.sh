#/bin/bash
#Author: Alex Antonov
#A simple program that backs up a database and
#sends the backup to a FTP server using lftp

NBTK=45 #number of backup copies to keep assuming backup runs once a day
MUSER=
MPASSWORD=
DBNAME=
FTPUSER=
FTPPASSWORD=
FTPSERVER=
BDIR=/usr/local/backup/db
DATE=`date +%F`

/usr/bin/mysqldump -u$MUSER -p$MPASSWORD --single-transaction $DBNAME | gzip -5 > $BDIR/$DBNAME_$DATE.sql.gz
/usr/bin/find $BDIR/ -type f -mtime +$NBTK -exec rm -f {} \;
lftp -u $FTPUSER,$FTPPASSWORD $FTPSERVER << EOF
	mirror -Re --delete --use-cache --only-newer $BDIR /backup
	quit 0
EOF
logger "the DB has been backed up"
