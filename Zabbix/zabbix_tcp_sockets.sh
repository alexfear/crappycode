#!/bin/bash
rval=0
TMPF=`ss -na | cut -f1 -d " " | sort |uniq -c`

if [[ -z $TMPF ]]; then
    echo "ZBX_NOTSUPPORTED"
    exit 1
fi

CASE_VALUE=$1

function usage() {
    echo "usage: "
    echo "$0 establ             --Established connections count"
    echo "$0 synsent            --SYN-SENT count"
    echo "$0 synrecv            --SYN-RECV count"
    echo "$0 finw1              --FIN-WAIT-1 count"
    echo "$0 finw2              --FIN-WAIT-2 count"
    echo "$0 timew              --TIME-WAIT count"
    echo "$0 closew             --CLOSE-WAIT count"
    echo "$0 listen             --LISTEN count"
}

case $CASE_VALUE in
'establ')
    echo "$TMPF" | grep "ESTAB" | awk '{print($1)}'
    rval=$?;;
'synsent')
    echo "$TMPF" | grep "SYN-SENT" | awk '{print($1)}'
    rval=$?;;
'synrecv')
    echo "$TMPF" | grep "SYN-RECV" | awk '{print($1)}'
    rval=$?;;
'finw1')
    echo "$TMPF" | grep "FIN-WAIT-1" | awk '{print($1)}'
    rval=$?;;
'finw2')
    echo "$TMPF" | grep "FIN-WAIT-2" | awk '{print($1)}'
    rval=$?;;
'timew')
    echo "$TMPF" | grep "TIME-WAIT" | awk '{print($1)}'
    rval=$?;;
'closew')
    echo "$TMPF" | grep "CLOSE-WAIT" | awk '{print($1)}'
    rval=$?;;
'listen')
    echo "$TMPF" | grep "LISTEN" | awk '{print($1)}'
    rval=$?;;
*)
    usage
    exit $rval;;
esac

if [ "$rval" -ne 0 ]; then
    echo "ZBX_NOTSUPPORTED"
fi

exit $rval
