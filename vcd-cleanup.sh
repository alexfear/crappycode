#!/bin/bash
## This program removes
## - vApps/vApp Templates
## - Medias(ISO's)
## - Org Networks
## - Edge Gateways
## - Catalogs
## - Org VDCs
## - Organizations

CURL=$(which curl)
MARKER='!!!' # the flag defines which entites will not be removed

usage() {
  echo "Usage: $0 -h hostname -u username -p password"
}

# Parsing arguments
while getopts ":h:u:p:" opt; do
  case ${opt} in
    h) 
      VCD_HOST=$OPTARG
      ;;
    u)
      VCD_USER=$OPTARG
      ;;
    p)
      VCD_PASSWORD=$OPTARG
      ;;
    \?)
      echo "Invalid option: $OPTARG"
      exit 1
      ;;
    :)
      echo "$OPTARG requires an argument"
      exit 1
      ;;
  esac
done

if [ $OPTIND -eq 1 ]; then
  usage
  exit 1
fi

shift $((OPTIND-1))

API_VERSION=$($CURL -s -i -k -H "Accept:application/*+xml" -X GET https://$VCD_HOST/api/versions | grep -A1 'deprecated="false"' | egrep -o '<Version>[0-9.]+' | cut -d'>' -f2 | tail -n 1)
echo "Using API version: $API_VERSION"

echo "Logging in..."
TOKEN=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -u $VCD_USER@system:$VCD_PASSWORD -X POST https://$VCD_HOST/api/sessions | egrep -o "x-vcloud-authorization\:\ [a-z0-9]+" | cut -d' ' -f2)

echo "vApps that will not be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filter=name==$MARKER*" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=]+\""| cut -d'"' -f2
