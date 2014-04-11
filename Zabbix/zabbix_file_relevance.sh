#!/bin/bash
## Script checks if the file is relevant by calculating the difference between NOW_TIME and file's MODIFIED_TIME.
## Time of relevance, path and file's name are set by parameters.
usage(){
        echo "Usage:"
        echo "$0 -p path -f file -t atime"
        echo "path      --path to file"
        echo "file      --file to check"
        echo "atime     --time of relevance in minutes"
}
while getopts p:f:t: opt; do
    case "$opt" in
        p)
            path=${OPTARG}
            ;;
        f)
            file=${OPTARG}
            ;;
        t)
            atime=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
result=`/usr/bin/find $path -name $file -type f ! -size 0 -mmin -$atime`
[[ -z $result ]] && echo "1" || echo "0"
