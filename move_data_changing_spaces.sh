#!/bin/bash
football24="/mnt/data/vc_football_to_send/"
channel24="/mnt/data/vc_24tv_to_send/"
lviv24="/mnt/data/vc_lviv24_to_send/"
zaxid="/mnt/data/vc_zaxid_to_send/"
export PIDFILE="/var/run/sync.pid"

if [ -f "$PIDFILE" ];
then 
	echo "Already running..." ;
	exit 0 ; 
else
	ps -fe | grep "move_data" | grep -v "grep" | awk '{print $2}' > $PIDFILE ;

	if ping -c 1 ip_address >/dev/null
	then
		/usr/bin/find /mnt/vc_football/ -type f -size +0k -mmin +2 -exec  mv {} "$football24" \;
		cd "$football24" ;
	        for file in *
	        do
		temp1=`echo ${file} | sed s:' ':'_':g` ;
		mv "$file" $temp1 ;
        	if scp "$football24$temp1" rsync@ip_address:/mnt/video/football24/sync/temporary >/dev/null ;
                then 
			rm -f "$football24$temp1" ;
	        fi
        	done
		
		/usr/bin/find /mnt/vc_24tv/ -type f -size +0k -mmin +2 -exec mv {} "$channel24" \;
		cd "$channel24" ;
        	for file in *
 	        do
                temp2=`echo ${file} | sed s:' ':'_':g` ;
                mv "$file" $temp2 ;
        	if scp "$channel24$temp2" rsync@ip_address:/mnt/data_video/temporary >/dev/null ;
                then 
			rm -f "$channel24$temp2" ; 
		fi
	        done

		/usr/bin/find /mnt/vc_lviv24/ -type f -size +0k -mmin +2 -exec mv {} "$lviv24" \;
		cd "$lviv24"
        	for file in *
	        do
                temp3=`echo ${file} | sed s:' ':'_':g` ;
                mv "$file" $temp3 ;
        	if scp "$lviv24$temp3" rsync@ip_address:/mnt/data_video/video/temporary >/dev/null ;
                then 
			rm -f "$lviv24$temp3" ; 
		fi
	        done

		/usr/bin/find /mnt/vc_zaxid/ -type f -size +0k -mmin +2 -exec mv {} "$zaxid" \;
		cd "$zaxid"
		for file in *
		do
                temp4=`echo ${file} | sed s:' ':'_':g` ;
                mv "$file" $temp4 ;
		if scp "$zaxid$temp4" rsync@ip_address:/mnt/data/resources/videos/temporary >/dev/null ; 
		then 
			rm -f "$zaxid$temp4" ; 
		fi
		done
	fi
	rm -f "$PIDFILE"
fi
