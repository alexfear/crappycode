#!/bin/bash
rval=0
TMPF=`/usr/sbin/nfsstat -4 -s -l`
if [[ -z $TMPF ]]; then
  echo "ZBX_NOTSUPPORTED"
  exit 1
fi
CASE_VALUE=$1
function usage() {
  echo "usage: "
  echo "$0 access"
  echo "$0 close"
  echo "$0 delegreturn"
  echo "$0 getattr"
  echo "$0 getfh"
  echo "$0 lookup"
  echo "$0 open"
  echo "$0 open_conf"
  echo "$0 putfh"
  echo "$0 putrootfh"
  echo "$0 read"
  echo "$0 readdir"
  echo "$0 renew"
  echo "$0 restorefh"
  echo "$0 savefh"
  echo "$0 setcltid"
  echo "$0 setcltidconf"
}
case $CASE_VALUE in
'access')
  echo "$TMPF" | grep "access:" | awk '{print($5)}'
  rval=$?;;
'open')
  echo "$TMPF" | grep "open:" | awk '{print($5)}'
  rval=$?;;
'close')
  echo "$TMPF" | grep "close:" | awk '{print($5)}'
  rval=$?;;
'delegreturn')
  echo "$TMPF" | grep "delereturn:" | awk '{print($5)}'
  rval=$?;;
'getattr')
  echo "$TMPF" | grep "getattr:" | awk '{print($5)}'
  rval=$?;;
'setattr')
  echo "$TMPF" | grep "setattr:" | awk '{print($5)}'
  rval=$?;;
'getfh')
  echo "$TMPF" | grep "getfh:" | awk '{print($5)}'
  rval=$?;;
'lookup')
  echo "$TMPF" | grep "lookup:" | awk '{print($5)}'
  rval=$?;;
'open_conf')
  echo "$TMPF" | grep "open_conf:" | awk '{print($5)}'
  rval=$?;;
'putfh')
  echo "$TMPF" | grep "putfh:" | awk '{print($5)}'
  rval=$?;;
'putrootfh')
  echo "$TMPF" | grep "putrootfh:" | awk '{print($5)}'
  rval=$?;;
'read')
  echo "$TMPF" | grep "read:" | awk '{print($5)}'
  rval=$?;;
'write')
  echo "$TMPF" | grep "write:" | awk '{print($5)}'
  rval=$?;;
'readdir')
  echo "$TMPF" | grep "readdir:" | awk '{print($5)}'
  rval=$?;;
'renew')
  echo "$TMPF" | grep "renew:" | awk '{print($5)}'
  rval=$?;;
'restorefh')
  echo "$TMPF" | grep "restorefh:" | awk '{print($5)}'
  rval=$?;;
'savefh')
  echo "$TMPF" | grep "savefh:" | awk '{print($5)}'
  rval=$?;;
'setcltid')
  echo "$TMPF" | grep "setcltid:" | awk '{print($5)}'
  rval=$?;;
'setcltidconf')
  echo "$TMPF" | grep "setcltidconf:" | awk '{print($5)}'
  rval=$?;;
'commit')
  echo "$TMPF" | grep "commit:" | awk '{print($5)}'
  rval=$?;;
'readlink')
  echo "$TMPF" | grep "readlink:" | awk '{print($5)}'
  rval=$?;;
'create')
  echo "$TMPF" | grep "create:" | awk '{print($5)}'
  rval=$?;;
'remove')
  echo "$TMPF" | grep "remove:" | awk '{print($5)}'
  rval=$?;;
'rename')
  echo "$TMPF" | grep "rename:" | awk '{print($5)}'
  rval=$?;;
*)
  usage
  exit $rval;;
esac
if [ "$rval" -ne 0 ]; then
  echo "ZBX_NOTSUPPORTED"
fi
exit $rval
