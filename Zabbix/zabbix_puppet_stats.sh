#!/bin/bash
rval=0
TMPF=`cat /var/lib/puppet/state/last_run_summary.yaml`
if [[ -z $TMPF ]]; then
echo "ZBX_NOTSUPPORTED"
exit 1
fi
CASE_VALUE=$1
function usage() {
echo "usage: "
echo "$0 r_total total resources"
echo "$0 r_skipped skipped resources"
echo "$0 r_changed changed resources"
echo "$0 r_restarted restarted resources"
echo "$0 r_scheduled scheduled resources"
echo "$0 r_failed_to_restart failed to restart resources"
echo "$0 r_out_of_sync out of sync resources"
echo "$0 r_failed faild resources"
echo "$0 t_total total run time"
echo "$0 t_exec exec run time"
echo "$0 t_service service run time"
echo "$0 t_package package run time"
echo "$0 t_file file run time"
echo "$0 t_last_run time of the last run"
echo "$0 t_config_retrieval config retrieval time"
echo "$0 t_filebucket filebucket run time"
echo "$0 t_cron cron run time"
echo "$0 t_user user run time"
echo "$0 version puppet version"
echo "$0 c_version puppet config version"
echo "$0 e_total total events"
echo "$0 e_failure failed events"
echo "$0 e_success successful events"
}
case $CASE_VALUE in
'r_total')
echo "$TMPF" | grep -A8 "resources:" | grep -m 1 "total:" | awk '{print $2}'
rval=$?;;
'r_skipped')
echo "$TMPF" | grep "skipped:" | awk '{print $2}'
rval=$?;;
'r_changed')
echo "$TMPF" | grep "changed:" | awk '{print $2}'
rval=$?;;
'r_restarted')
echo "$TMPF" | grep "restarted:" | awk '{print $2}'
rval=$?;;
'r_scheduled')
echo "$TMPF" | grep "scheduled:" | awk '{print $2}'
rval=$?;;
'r_failed_to_restart')
echo "$TMPF" | grep "failed_to_restart:" | awk '{print $2}'
rval=$?;;
'r_out_of_sync')
echo "$TMPF" | grep "out_of_sync:" | awk '{print $2}'
rval=$?;;
'r_failed')
echo "$TMPF" | grep "failed:" | awk '{print $2}'
rval=$?;;
't_total')
echo "$TMPF" | grep -A10 "time:" | grep -m 1 "total:" | awk '{print $2}'
rval=$?;;
't_exec')
echo "$TMPF" | grep "exec:" | awk '{print $2}'
rval=$?;;
't_service')
echo "$TMPF" | grep "service:" | awk '{print $2}'
rval=$?;;
't_package')
echo "$TMPF" | grep "package:" | awk '{print $2}'
rval=$?;;
't_file')
echo "$TMPF" | grep "file:" | awk '{print $2}'
rval=$?;;
't_last_run')
echo "$TMPF" | grep "last_run:" | awk '{print $2}'
rval=$?;;
't_config_retrieval')
echo "$TMPF" | grep "config_retrieval:" | awk '{print $2}'
rval=$?;;
't_filebucket')
echo "$TMPF" | grep "filebucket:" | awk '{print $2}'
rval=$?;;
't_cron')
echo "$TMPF" | grep "cron:" | awk '{print $2}'
rval=$?;;
't_user')
echo "$TMPF" | grep "user:" | awk '{print $2}'
rval=$?;;
'version')
echo "$TMPF" | grep "puppet:" | awk '{print $2}'
rval=$?;;
'c_version')
echo "$TMPF" | grep "config:" | awk '{print $2}'
rval=$?;;
'e_total')
echo "$TMPF" | grep -A3 "events:" | grep -m 1 "total:" | awk '{print $2}'
rval=$?;;
'e_failure')
echo "$TMPF" | grep "failure:" | awk '{print $2}'
rval=$?;;
'e_success')
echo "$TMPF" | grep "success:" | awk '{print $2}'
rval=$?;;
*)
usage
exit $rval;;
esac
if [ "$rval" -ne 0 ]; then
echo "ZBX_NOTSUPPORTED"
fi
exit $rval