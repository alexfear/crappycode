#!/bin/bash
## Author: Alex Antonov
## The program backs up all databases of a mysql server 
## Excluding ones from the exclusion list and 
## Truncating tables which names start with "cache".
## The backup directory is sent to a remote host then.
BACKUPDIR=/usr/local/backup/mysql
MUSER=""
MPASS=""
MHOST=""
BACKUPHOST=""
DATESTAMP=$(date +%F)
EXCLUDE_DBS=""

# backup function
backup(){
    [ -d $BACKUPDIR ] && /bin/rm -f $BACKUPDIR/*
    [ ! -d $BACKUPDIR ] && /bin/mkdir -p $BACKUPDIR
    local dblist=$(/usr/bin/mysql -u$MUSER -h$MHOST -p$MPASS -Bse 'show databases'| egrep -v "$EXCLUDE_DBS")
    local db=""
    for db in $dblist; do
        tables_for_truncation=$(/usr/bin/mysql -u$MUSER -h$MHOST -p$MPASS --execute="select table_name from information_schema.tables where table_schema='$db' and table_name like 'cache_%';")
        for table in $tables_for_truncation; do
		/usr/bin/mysql -u$MUSER -h$MHOST -p$MPASS --execute="use $db; truncate table $table;";
	done
        /usr/bin/mysqldump -u$MUSER -h$MHOST -p$MPASS --single-transaction $db | /bin/gzip -9 > $BACKUPDIR/"$db"_"$DATESTAMP".sql.gz
    done
    /usr/bin/rsync -aqz --rsh="ssh -p33322" --delete $BACKUPDIR rsync@"$BACKUPHOST":/usr/local/backup/sitepack1/
    logger " DBs are backed up"
}

# MAIN
backup
