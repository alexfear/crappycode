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

# Getting the latest API version for the vCD instance
API_VERSION=$($CURL -s -i -k -H "Accept:application/*+xml" -X GET https://$VCD_HOST/api/versions | grep -A1 'deprecated="false"' | egrep -o '<Version>[0-9.]+' | cut -d'>' -f2 | tail -n 1)
echo "Using API version: $API_VERSION"

# Getting a session token
echo "Logging in..."
TOKEN=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -u $VCD_USER@system:$VCD_PASSWORD -X POST https://$VCD_HOST/api/sessions | egrep -o "x-vcloud-authorization\:\ [a-z0-9]+" | cut -d' ' -f2)

# Querying vApps that will not be removed
VAPPS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filter=name==$MARKER*" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)
echo "The following vApps will not be removed"
echo $VAPPS_TO_KEEP

# Building a filter expression based on vApp names,
# it will make sure vApps that must not be deleted,
# will be excluded from the "vApps to remove" query
for VAPP_TO_KEEP in $VAPPS_TO_KEEP; do
  FILTER+="name!=$VAPP_TO_KEEP;"
done
FILTER=$(echo $FILTER | sed 's/;$//g')

# Querying vApps to be removed
VAPPS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminVAppRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)
echo "HREFs of the vApps to be removed:"
echo $VAPPS_TO_REMOVE | tr ' ' '\n'