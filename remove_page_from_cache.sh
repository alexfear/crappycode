#!/bin/bash
## Script removing pages from nginx cache by executing curl with "X-Update: 1" header

LOGGING=1		#turn logging on=1/off=0
CURL=/usr/bin/curl	#curl binary
URL="$1"		#url is the first parameter
LANG="$2"		#language is the second parameter
LOGFILE=/var/log/remove_page_from_cache.log

die() {
    TS=`date +%Y-%m-%d\ %H:%M:S`
    echo "$TS $@" 1>&2 >> $LOGFILE
    exit 1
}

if [[ $LOGGING -eq 1 ]]; then
    [[ -f $CURL ]] || die "curl is not installed or path to curl binary is incorrect"
    [[ "$URL" != "" ]] || die "URL is empty"
    [[ "$LANG" != "ru" && "$LANG" != "uk" ]] && die "Language parameter is invalid: '$LANG'"
fi

## Removing ukrainian pages from cache
if [[ "$LANG" == "uk" ]]; then
        $CURL -s -o /dev/null -H "X-Update: 1" http://example.com
fi

## Removing russian pages from cache
if [[ "$LANG" == "ru" ]]; then
        $CURL -s -o /dev/null -H "X-Update: 1" http://example.com/?lang=ru
fi

if [[ $LOGGING -eq 1 ]]; then
    TS=`date +%Y-%m-%d\ %H:%M:S`
    echo "$TS Page '$URL' in '$LANG' language has been removed from nginx cache" >> $LOGFILE
fi
exit 0
