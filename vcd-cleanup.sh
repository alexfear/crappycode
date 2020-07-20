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
echo "Getting supported API versions..."
SUPPORTED_API_VERSIONS=$($CURL -s -i -k -H "Accept:application/*+xml" -X GET https://$VCD_HOST/api/versions | grep -A1 'deprecated="false"' | egrep -o '<Version>[0-9.]+' | cut -d'>' -f2)
echo -e "$SUPPORTED_API_VERSIONS"
API_VERSION=$(echo $SUPPORTED_API_VERSIONS | tr ' ' '\n' | tail -n 1)
echo "Using API version $API_VERSION"

# Getting a session token
printf "Logging in... "
TOKEN=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -u $VCD_USER@system:$VCD_PASSWORD -X POST https://$VCD_HOST/api/sessions | egrep -o "x-vcloud-authorization\:\ [a-z0-9]+" | cut -d' ' -f2)
if [ $TOKEN ]; then
  echo "OK"
else 
  echo "Error: unahthorized, check the credentials" && exit 1; 
fi

# Querying vApps to keep
VAPPS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filter=name==$MARKER*" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApps from being deleted
FILTER=''
for VAPP_TO_KEEP in $VAPPS_TO_KEEP; do
  FILTER+="name!=$VAPP_TO_KEEP;"
done
FILTER=$(echo $FILTER | sed 's/;$//g')

# Querying vApps to remove
echo "+++ The following vApp will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPPS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminVAppRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying vApps Templates to keep
VAPP_TEMPLATES_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filter=name==$MARKER*" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApp Templates from being deleted
FILTER=''
for VAPP_TEMPLATE_TO_KEEP in $VAPP_TEMPLATES_TO_KEEP; do
  FILTER+="name!=$VAPP_TEMPLATE_TO_KEEP;"
done
FILTER=$(echo $FILTER | sed 's/;$//g')

# Querying vApp Templates to remove
echo "+++ The following vApp Templates will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPP_TEMPLATES_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminVAppTemplateRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Medias to keep
MEDIAS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filter=name==$MARKER*" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Medias from being deleted
FILTER=''
for MEDIA_TO_KEEP in $MEDIAS_TO_KEEP; do
  FILTER+="name!=$MEDIA_TO_KEEP;"
done
FILTER=$(echo $FILTER | sed 's/;$//g')

# Querying Medias to remove
echo "+++ The following Medias(ISOs) will be removed:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
MEDIAS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=($FILTER)" | grep -i AdminMediaRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Removing session
echo "Logging out..."
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X DELETE "https://$VCD_HOST/api/session" >/dev/null
