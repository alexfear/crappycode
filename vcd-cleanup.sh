#!/bin/bash
## Author: Alex Antonov
## This program removes
## - vApps
## - vApp Templates
## - Medias (ISO's)
## - Catalogs
## - Org Networks
## - Edge Gateways
## - Org VDCs
## - Organizations

CURL=$(which curl)
MARKER='!!!' # the entities which names start with the MARKER will NOT be touched

usage() {
  echo "Usage: $0 -h hostname -u username -p password"
}

logout() {
  echo "Logging out from the vCD..."
  $CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X DELETE "https://$VCD_HOST/api/session" >/dev/null
}

vapp_deployed() {
  $CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "$1" | egrep -o "deployed=\"[a-z]+\"" | cut -d'"' -f2 | head -1
}

undeploy_vapp() {
  UNDEPLOY_TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -H "Content-Type:application/vnd.vmware.vcloud.undeployVAppParams+xml" -X POST -d '<UndeployVAppParams xmlns="http://www.vmware.com/vcloud/v1.5"><UndeployPowerAction>powerOff</UndeployPowerAction></UndeployVAppParams>' "$1/action/undeploy")
  UNDEPLOY_TASK_HREF=$(echo $UNDEPLOY_TASK | grep -i "<Task" | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)
  UNDEPLOY_TASK_ERROR_MESSAGE=$(echo $UNDEPLOY_TASK | egrep -o "message=\"\[\ [a-zA-Z0-9-]+\ \]\ [a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)
  if [ "$UNDEPLOY_TASK_HREF" ]; then
    task_progress $UNDEPLOY_TASK_HREF "Undeploying $1... "
  else
    echo "Undeploying $1 failed: $UNDEPLOY_TASK_ERROR_MESSAGE"
  fi
}

delete_entity() {
  DELETE_TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X DELETE "$1")
  DELETE_TASK_HREF=$(echo $DELETE_TASK | grep -i "<Task" | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2 | tr " " "\n" | head -1)
  DELETE_TASK_ERROR_MESSAGE=$(echo $DELETE_TASK | egrep -o "message=\"\[\ [a-zA-Z0-9-]+\ \]\ [a-zA-Z0-9!_+-:,;=()&/ ]+\"" | cut -d'"' -f2)
  if [ "$DELETE_TASK_HREF" ]; then
    task_progress $DELETE_TASK_HREF "Deleting $1... "
  else
    echo "Deleting $1... failed: $DELETE_TASK_ERROR_MESSAGE"
  fi
}

task_progress() {
  while true; do
    TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "$1")
    TASK_STATUS=$(echo $TASK | egrep -o "status=\"[a-z]+\"" | cut -d'"' -f2 | head -1)
    TASK_ERROR_MESSAGE=$(echo $TASK | egrep -o "message=\"\[\ [a-zA-Z0-9-]+\ \]\ [a-zA-Z0-9!_+-:,;=()&/ ]+\"" | cut -d'"' -f2)
    printf "$2 $TASK_STATUS"\\r
    if [ "$TASK_STATUS" == "success" ]|| [ "$TASK_STATUS" == "aborted" ]; then
      echo
      break
    fi
    if [ "$TASK_STATUS" == "error" ]; then
      echo "$2 $TASK_STATUS: $TASK_ERROR_MESSAGE"
      break
    fi
    sleep 2
  done
}

query_filter() {
  FILTER=''
  for ENTITY in $@; do
    FILTER+="name!=$ENTITY;"
  done
  echo $FILTER | sed 's/;$//g'
}

vdc_enabled() {
  $CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "$1" | egrep -o "rel=\"disable\""
}

disable_vdc() {
  printf "Disabling $1... "\\r
  TASK=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X POST "$1/action/disable" | egrep -o "204")
  echo "Disabling $1... ok"
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
VAPPS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filter=name==$MARKER*" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApps from being deleted
FILTER=''
if [ "$VAPPS_TO_KEEP" ]; then
  FILTER=$(query_filter $VAPPS_TO_KEEP)
fi  

# Querying vApps to remove
echo "+++ The following vApps will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPPS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVApp&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying vApps Templates to keep
VAPP_TEMPLATES_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filter=name==$MARKER*" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the vApp Templates from being deleted
FILTER=''
if [ "$VAPP_TEMPLATES_TO_KEEP" ]; then
  FILTER=$(query_filter $VAPP_TEMPLATES_TO_KEEP)
fi 

# Querying vApp Templates to remove
echo "+++ The following vApp Templates will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppTemplateRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VAPP_TEMPLATES_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminVAppTemplate&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVAppTemplateRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Media (ISO's) to keep
MEDIAS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filter=name==$MARKER*" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Medias from being deleted
FILTER=''
if [ "$MEDIAS_TO_KEEP" ]; then
  FILTER=$(query_filter $MEDIAS_TO_KEEP)
fi

# Querying Media (ISO's) to remove
echo "+++ The following Media (ISOs) will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminMediaRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
MEDIAS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminMedia&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminMediaRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Catalogs to keep
CATALOGS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminCatalog&fields=name&filter=name==$MARKER*" | grep -i AdminCatalogRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Catalogs from being deleted
FILTER=''
if [ "$CATALOGS_TO_KEEP" ]; then
  FILTER=$(query_filter $CATALOGS_TO_KEEP)
fi

# Querying Catalogs to remove
echo "+++ The following Catalogs will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminCatalog&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminCatalogRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
CATALOGS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminCatalog&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminCatalogRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2 | sed 's:catalog:admin\/catalog:g')

# Querying Org Networks to keep
ORG_NETWORKS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=orgVdcNetwork&fields=name&filter=name==$MARKER*" | grep -i OrgVdcNetworkRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Org Networks from being deleted
FILTER=''
if [ "$ORG_NETWORKS_TO_KEEP" ]; then
  FILTER=$(query_filter $ORG_NETWORKS_TO_KEEP)
fi

# Querying Org Networks to remove
echo "+++ The following Org Networks will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=orgVdcNetwork&fields=name&filterEncoded=true&filter=$FILTER" | grep -i OrgVdcNetworkRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
ORG_NETWORKS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=orgVdcNetwork&fields=name&filterEncoded=true&filter=$FILTER" | grep -i OrgVdcNetworkRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Edge Gateways to keep
GATEWAYS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=edgeGateway&fields=name&filter=name==$MARKER*" | grep -i EdgeGatewayRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Edge Gateways from being deleted
FILTER=''
if [ "$GATEWAYS_TO_KEEP" ]; then
  FILTER=$(query_filter $GATEWAYS_TO_KEEP)
fi

# Querying Edge Gateways to remove
echo "+++ The following Edge Gateways will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=edgeGateway&fields=name&filterEncoded=true&filter=$FILTER" | grep -i EdgeGatewayRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
GATEWAYS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=edgeGateway&fields=name&filterEncoded=true&filter=$FILTER" | grep -i EdgeGatewayRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Querying Org VDC's to keep
VDCS_TO_KEEP=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminOrgVdc&fields=name&filter=name==$MARKER*" | grep -i AdminVdcRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2)

# Building a filter to prevent the Org VDC's from being deleted
FILTER=''
if [ "$VDCS_TO_KEEP" ]; then
  FILTER=$(query_filter $VDCS_TO_KEEP)
fi

# Querying Org VDC's to remove
echo "+++ The following Org VDC's will be deleted:"
$CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminOrgVdc&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVdcRecord | egrep -o "name=\"[a-zA-Z0-9!_+-:,;=/ ]+\"" | cut -d'"' -f2 | sed 's/^.*$/\ \ \ \ &/g'
VDCS_TO_REMOVE=$($CURL -s -i -k -H "Accept:application/*+xml;version=$API_VERSION" -H "x-vcloud-authorization:$TOKEN" -X GET "https://$VCD_HOST/api/query?type=adminOrgVdc&fields=name&filterEncoded=true&filter=$FILTER" | grep -i AdminVdcRecord | egrep -o "href=\"[a-zA-Z0-9_+-:,;=/]+\"" | cut -d'"' -f2)

# Warning user about consequences and asking to confirm the deletion of the entities
while true; do
  printf "\e[1;31mDo you want to proceed to delete the entities mentioned above (this is irreversable)? (y/n): \e[0m"
  read -n 1 -p "" yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) echo; logout; exit 0;;
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

# Removing Media (ISO's)
if [ "$MEDIAS_TO_REMOVE" ]; then 
  for MEDIA in $MEDIAS_TO_REMOVE; do
    delete_entity $MEDIA
  done
fi

# Removing Catalogs
if [ "$CATALOGS_TO_REMOVE" ]; then 
  for CATALOG in $CATALOGS_TO_REMOVE; do
    delete_entity $CATALOG
  done
fi

# Removing Org Networks
if [ "$ORG_NETWORKS_TO_REMOVE" ]; then 
  for ORG_NETWORK in $ORG_NETWORKS_TO_REMOVE; do
    delete_entity $ORG_NETWORK
  done
fi

# Removing Edge Gateways
if [ "$GATEWAYS_TO_REMOVE" ]; then 
  for GATEWAY in $GATEWAYS_TO_REMOVE; do
    delete_entity $GATEWAY
  done
fi

# Removing Org VDC's
if [ "$VDCS_TO_REMOVE" ]; then 
  for VDC in $VDCS_TO_REMOVE; do
    if [ $(vdc_enabled $VDC) ]; then
      disable_vdc $VDC
    fi
    delete_entity $VDC
  done
fi

logout
