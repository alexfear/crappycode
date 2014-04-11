#!/bin/bash
function usage() {
echo "usage: "
echo "$0 nginx_stub_url active --Active connections"
echo "$0 nginx_stub_url accepts --Accepted connections"
echo "$0 nginx_stub_url handled --Handled connections"
echo "$0 nginx_stub_url requests --Requests"
echo "$0 nginx_stub_url read --Reading"
echo "$0 nginx_stub_url write --Writing"
echo "$0 nginx_stub_url wait --Waiting"
echo "$0 nginx_stub_url version --Nginx version"
}

rval=0
stub_url="$1"
metric="$2"

TMPF=`curl -s --insecure "$stub_url"`

if [[ -z $TMPF ]]; then
echo "ZBX_NOTSUPPORTED"
exit 1
fi

case $metric in
'active')
echo "$TMPF"| grep "Active connections" | cut -f3 -d " "
rval=$?;;
'accepts')
echo "$TMPF"| sed -n '3p' | cut -f2 -d " "
rval=$?;;
'handled')
echo "$TMPF"| sed -n '3p' | cut -f3 -d " "
rval=$?;;
'requests')
echo "$TMPF"| sed -n '3p' | cut -f4 -d " "
rval=$?;;
'read')
echo "$TMPF"| grep "Reading" | cut -f2 -d " "
rval=$?;;
'write')
echo "$TMPF"| grep "Writing" | cut -f2 -d " "
rval=$?;;
'wait')
echo "$TMPF"| grep "Waiting" | cut -f2 -d " "
rval=$?;;
'version')
nginx -v 2>&1 | cut -f2 -d"/"
rval=$?;;
*)
usage;
exit $rval;;
esac

if [ "$rval" -ne 0 ]; then
echo "ZBX_NOTSUPPORTED"
fi

exit $rval