#!/bin/bash
export PIDFILE="/var/run/sync.pid"

if [ -f "$PIDFILE" ];
then 
	echo "Already running..." ;
	exit 0 ; 
else
	ps -fe | grep "move_data" | grep -v "grep" | awk '{print $2}' > $PIDFILE ;

	if ping -c 1 ip_address >/dev/null
	then
                /usr/bin/find /mnt/vc_football/ -type f -size +0k -mmin +3 -exec sh -c 'temp="{}" ; 
		if [[ ! $temp =~ \  ]] ;
		then 
			if scp "$temp" rsync@ip_address:/mnt/video/football24/sync/temporary >/dev/null ;
        	        then rm -f "$temp" ;
                	fi ;
		fi' sh '{}' \;

                /usr/bin/find /mnt/vc_24tv/ -type f -size +0k -mmin +3 -exec sh -c 'temp="{}" ;
                if [[ ! $temp =~ \  ]] ;
                then
                        if scp "$temp" rsync@ip_address:/mnt/data_video/temporary ;
                        then rm -f "$temp" ;
                        fi ;
                fi' sh '{}' \;

                /usr/bin/find /mnt/vc_lviv24/ -type f -size +0k -mmin +3 -exec sh -c 'temp="{}" ;
                if [[ ! $temp =~ \  ]] ;
                then
                        if scp "$temp" rsync@ip_address:/mnt/data_video/video/temporary ;
                        then rm -f "$temp" ;
                        fi ;
                fi' sh '{}' \;

                /usr/bin/find /mnt/vc_zaxid/ -type f -size +0k -mmin +3 -exec sh -c 'temp="{}" ;
                if [[ ! $temp =~ \  ]] ;
                then
                        if scp "$temp" rsync@ip_address:/mnt/data/resources/videos/temporary ;
                        then rm -f "$temp" ;
                        fi ;
                fi' sh '{}' \;

	fi
	rm -f "$PIDFILE"
fi
