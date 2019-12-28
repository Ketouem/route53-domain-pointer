#!/usr/bin/env bash

declare DOMAIN_NAME=$1;
DOMAIN_NAME=$(echo $DOMAIN_NAME | tr '[:upper:]' '[:lower:]');
declare ZONE_ID=$2;
declare -r TMP_LOCATION="/tmp/route53_domain_pointer_batch.json";

getPublicIP() {
  echo $(curl -s https://httpbin.org/ip | grep -oE "([0-9]{1,3}(\.?)){4}" | uniq);
}

getIPForDomain() {
  declare domain=$1;
  declare zoneId=$2;
  echo $(aws route53 list-resource-record-sets --hosted-zone-id $zoneId \
                                               --query "ResourceRecordSets[?Name == '${domain}.'].ResourceRecords[*].Value" \
                                               --output text);
}

updateRecordSet() {
  declare domainName=$1;
  declare ip=$2;
  declare zoneId=$3;
  cat << EOF > $TMP_LOCATION
{
  "Comment": "route53_domain_pointer update, generated $(date)",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${domainName}",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${ip}"
          }
        ]
      }
    }
  ]
}
EOF
  aws route53 change-resource-record-sets --hosted-zone-id $zoneId \
                                          --change-batch file://$TMP_LOCATION > /dev/null;
}

if [[ -z "${DOMAIN_NAME}" ]] || [[ -z "${ZONE_ID}" ]]|| [[ "${DOMAIN_NAME}" == "-h" ]]; then
  echo "Usage: route53_domain_pointer.sh <DOMAIN_NAME> <ZONE_ID>";
  echo "       DOMAIN_NAME: domain name handled by route53";
  echo "       ZONE_ID: route53 zone id of the record set";
  echo "       -h to display this help message";
else
  declare currentPublicIP=$(getPublicIP);
  declare recordedIp=$(getIPForDomain $DOMAIN_NAME $ZONE_ID);
  if [[ "${currentPublicIP}" == "${recordedIp}" ]]; then
    echo "Domain ${DOMAIN_NAME} currently points to the retrieved public IP ${currentPublicIP}.";
  else
    echo -n "Record set for ${DOMAIN_NAME} out of date (${recordedIp}), updating it to ${currentPublicIP}...";
    updateRecordSet $DOMAIN_NAME $currentPublicIP $ZONE_ID;
    if [[ $? -ne 0 ]]; then
      echo "❌ error occured during the update";
    else
      echo "✅";
      rm $TMP_LOCATION;
    fi
  fi
fi
