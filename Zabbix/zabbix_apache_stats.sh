#! /bin/bash
#
# Name: zapache
#
# Checks Apache activity.
#
# Author: Alejandro Michavila
# Modified for Scoreboard Values: Murat Koc, murat@profelis.com.tr
# Modified for using also as external script: Murat Koc, murat@profelis.com.tr
# Modified for outputting usage or ZBX_NOTSUPPORTED: Alejandro Michavila
#
# Version: 1.4
#
Ê
rval=0
Ê
function usage()
{
echo "usage:"
echo " $0 TotalAccesses -- Check total accesses."
echo " $0 TotalKBytes -- Check total KBytes."
echo " $0 Uptime -- Check uptime."
echo " $0 ReqPerSec -- Check requests per second."
echo " $0 BytesPerSec -- Check Bytes per second."
echo " $0 BytesPerReq -- Check Bytes per request."
echo " $0 BusyWorkers -- Check busy workers."
echo " $0 IdleWorkers -- Check idle workers."
echo " $0 version -- Version of this script."
echo " $0 WaitingForConnection -- Check Waiting for Connection processess."
echo " $0 StartingUp -- Check Starting Up processess."
echo " $0 ReadingRequest -- Check Reading Request processess."
echo " $0 SendingReply -- Check Sending Reply processess."
echo " $0 KeepAlive -- Check KeepAlive Processess."
echo " $0 DNSLookup -- Check DNSLookup Processess."
echo " $0 ClosingConnection -- Check Closing Connection Processess."
echo " $0 Logging -- Check Logging Processess."
echo " $0 GracefullyFinishing -- Check Gracefully Finishing Processess."
echo " $0 IdleCleanupOfWorker -- Check Idle Cleanup of Worker Processess."
echo " $0 OpenSlotWithNoCurrentProcess -- Check Open Slots with No Current Process."
}
Ê
########
# Main #
########
Ê
if [[ $# == 1 ]];then
#Agent Mode
VAR=$(wget --quiet -O - http://localhost/server-status?auto)
CASE_VALUE=$1
elif [[ $# == 2 ]];then
#External Script Mode
VAR=$(wget --quiet -O - http://$1/server-status?auto)
CASE_VALUE=$2
else
#No Parameter
usage
exit 0
fi
Ê
if [[ -z $VAR ]]; then
echo "ZBX_NOTSUPPORTED"
exit 1
fi
Ê
case $CASE_VALUE in
'TotalAccesses')
echo "$VAR"|grep "Total Accesses:"|cut -f3 -d " "
rval=$?;;
'TotalKBytes')
echo "$VAR"|grep "Total kBytes:"| cut -f3 -d " "
rval=$?;;
'Uptime')
myvar=$(echo "$VAR"|grep "Uptime:"| cut -f2 -d " ")
echo "$myvar/60"|bc
rval=$?;;
'ReqPerSec')
echo "$VAR"|grep "ReqPerSec:"| cut -f2 -d " "
rval=$?;;
'BytesPerSec')
echo "$VAR"|grep "BytesPerSec:"| cut -f2 -d " "
rval=$?;;
'BytesPerReq')
echo "$VAR"|grep "BytesPerReq:"| cut -f2 -d " "
rval=$?;;
'BusyWorkers')
echo "$VAR"|grep "BusyWorkers:"| cut -f2 -d " "
rval=$?;;
'IdleWorkers')
echo "$VAR"|grep "IdleWorkers:"| cut -f2 -d " "
rval=$?;;
'WaitingForConnection')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "_" } ; { print NF-1 }'
rval=$?;;
'StartingUp')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "S" } ; { print NF-1 }'
rval=$?;;
'ReadingRequest')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "R" } ; { print NF-1 }'
rval=$?;;
'SendingReply')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "W" } ; { print NF-1 }'
rval=$?;;
'KeepAlive')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "K" } ; { print NF-1 }'
rval=$?;;
'DNSLookup')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "D" } ; { print NF-1 }'
rval=$?;;
'ClosingConnection')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "C" } ; { print NF-1 }'
rval=$?;;
'Logging')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "L" } ; { print NF-1 }'
rval=$?;;
'GracefullyFinishing')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "G" } ; { print NF-1 }'
rval=$?;;
'IdleCleanupOfWorker')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "I" } ; { print NF-1 }'
rval=$?;;
'OpenSlotWithNoCurrentProcess')
echo "$VAR"|grep "Scoreboard:"| cut -f2 -d " "| awk 'BEGIN { FS = "." } ; { print NF-1 }'
rval=$?;;
'version')
/usr/local/bin/apachectl -v | cut -f3 -d " "
rval=$?;;
'CPULoad')
echo "$VAR"|grep "CPULoad:"| cut -f2 -d " "
rval=$?;;
*)
usage
exit $rval;;
esac
Ê
if [ "$rval" -ne 0 ]; then
echo "ZBX_NOTSUPPORTED"
fi
Ê
exit $rval
Ê
#
# end zapache
