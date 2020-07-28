#!/bin/bash
## This program removes
## - vApps
## - vApp Templates
## - Medias(ISO's)
## - Org Networks
## - Edge Gateways
## - Catalogs
## - Org VDCs
## - Organizations

CURL=$(which curl)
MARKER='!!!' # the entities which names start with the MARKER will NOT be touched

usage() {
  echo "Usage: $0 -h hostname -u username -p password"
}

logout() {
  echo "Logging out from the vCD..."
  $CURL -s -i -k -H "Accept:application/*+xml;version=$3" -H "x-vcloud-authorization:$2" -X DELETE "https://$1/api/session" >/dev/null
}

vapp_deployed() {
  $CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "$1" | egrep -o "deployed=\"[a-z]+\"" | cut -d'"' -f2 | head -1
}

undeploy_vapp() {
  UNDEPLOY_TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -H "Content-Type:application/vnd.vmware.vcloud.undeployVAppParams+xml" -X POST -d '<UndeployVAppParams xmlns="http://www.vmware.com/vcloud/v1.5"><UndeployPowerAction>powerOff</UndeployPowerAction></UndeployVAppParams>' "$1/action/undeploy" | grep -i "<Task" | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)
  if [ "$UNDEPLOY_TASK" ]; then
    task_progress $UNDEPLOY_TASK "Undeploying $1... "
  fi
}

delete_entity() {
  DELETE_TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X DELETE "$1" | grep -i "<Task" | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)
  if [ "$DELETE_TASK" ]; then
    task_progress $DELETE_TASK "Deleting $1... "
  fi
}

task_progress() {
  while true; do
    STATUS=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "$1" | egrep -o "status=\"[a-z]+\"" | cut -d'"' -f2 | head -1)
    printf "$2 $STATUS"\\r
    if [ "$STATUS" == "success" ] || [ "$STATUS" == "error" ] || [ "$STATUS" == "aborted" ]; then
      echo
      break
    fi
    sleep 2
  done
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
if [ "$TOKEN" ]; then
  echo "OK"
else 
  echo "Error: unahthorized, check the credentials" && exit 1; 
fi

echo "The entities which names start with \"$MARKER\" will NOT be deleted"

# Querying vApps to keep
VAPPS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filter=name==$MARKER*" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApps from being deleted
FILTER=''
if [ "$VAPPS_TO_KEEP" ]; then
  for VAPP_TO_KEEP in $VAPPS_TO_KEEP; do
    FILTER+="name!=$VAPP_TO_KEEP;"
  done
  FILTER=$(echo $FILTER | sed 's/;$//g')
fi  

# Querying vApps to remove
echo "+++ The following vApps will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPPS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying vApps Templates to keep
VAPP_TEMPLATES_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filter=name==$MARKER*" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApp Templates from being deleted
FILTER=''
if [ "$VAPP_TEMPLATES_TO_KEEP" ]; then
  for VAPP_TEMPLATE_TO_KEEP in $VAPP_TEMPLATES_TO_KEEP; do
    FILTER+="name!=$VAPP_TEMPLATE_TO_KEEP;"
  done
  FILTER=$(echo $FILTER | sed 's/;$//g')
fi 

# Querying vApp Templates to remove
echo "+++ The following vApp Templates will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPP_TEMPLATES_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppTemplateRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Medias to keep
MEDIAS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filter=name==$MARKER*" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Medias from being deleted
FILTER=''
if [ "$MEDIAS_TO_KEEP" ]; then
  for MEDIA_TO_KEEP in $MEDIAS_TO_KEEP; do
    FILTER+="name!=$MEDIA_TO_KEEP;"
  done
  FILTER=$(echo $FILTER | sed 's/;$//g')
fi

# Querying Medias to remove
echo "+++ The following Media(ISOs) will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
MEDIAS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminMediaRecord | egrep -o "href=\"[a-zA-Z0-9!_+-:,;=/]+\"" | cut -d'"' -f2)

# Warning user about consequences and asking to confirm the deletion of the entities
while true; do
  printf "\e[1;31mDo you want to proceed to delete the entities mentioned above (this is irreversable)? (y/n): \e[0m"
  read -n 1 -p "" yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) echo; logout $VCD_HOST $TOKEN $API_VERSION; exit 0;;
    * ) echo "Correct answers are \"y\" and \"n\"";;
  esac
done

echo

# Removing vApps
if [ "$VAPPS_TO_REMOVE" ]; then
  for VAPP in $VAPPS_TO_REMOVE; do
    if [ "$(vapp_deployed $VAPP)" == "true" ]; then
      undeploy_vapp $VAPP
    fi
    delete_entity $VAPP
  done
fi

# Removing vApp Templates
if [ "$VAPP_TEMPLATES_TO_REMOVE" ]; then 
  for VAPP_TEMPLATE in $VAPP_TEMPLATES_TO_REMOVE; do
    delete_entity $VAPP_TEMPLATE
  done
fi

# Removing Media (ISOs)
if [ "$MEDIAS_TO_REMOVE" ]; then 
  for MEDIA in $MEDIAS_TO_REMOVE; do
    delete_entity $MEDIA
  done
fi

logout $VCD_HOST $TOKEN $API_VERSION
