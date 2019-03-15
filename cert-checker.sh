#!/bin/bash

# Author: https://github.com/electronicsleep
# Purpose: Check Certificate Expiry
# Released under the BSD license

set -e
FILE=cert-checker.txt
HOSTS="$(cat ${FILE})"

if [ -z "$HOSTS" ]; then
 echo "Add hosts to: ${FILE}"
 exit 1
fi

if ! [ -x "$(command -v dig)" ]; then
  echo 'Error: dig is not installed.' >&2
  exit 1
fi

EPOCH=$(date "+%s")
DAY=$(date "+%d")
MONTH=$(date "+%m")
YEAR=$(date "+%Y")

for HOST in ${HOSTS};
do
 IP=$(dig +short ${HOST} | tail -n 1)
 echo "_______________________"
 echo "### HOST: $HOST IP: $IP"
 INFO=$(echo -ne '\n' | openssl s_client -showcerts -servername ${HOST} -connect ${IP}:443 | openssl x509 -inform pem -noout -enddate)
 echo "$INFO" > ssl_info.txt
 EXPIRY=$(grep "notAfter" ssl_info.txt)
 EXPIRY_DATE=$(echo ${EXPIRY} | cut -f 2 -d =)
 EXPIRY_YEAR=$(echo ${EXPIRY_DATE} | cut -f 4 -d ' ')
 EXPIRY_DAY=$(echo ${EXPIRY_DATE} | cut -f 2 -d ' ')
 EXPIRY_MONTH=$(echo ${EXPIRY_DATE} | cut -f 1 -d ' ')
 echo "$EXPIRY"

 OS=$(uname)
 if [ "$OS" == "Darwin" ]; then
  #MacOS
  COMPARE=$(date -j -f "%d %b %Y %T %Z" "$EXPIRY_DAY $EXPIRY_MONTH $EXPIRY_YEAR 00:00:00 PST" +"%s")
 else
  #Linux
  if [ "${EXPIRY_MONTH}" == "Jan" ]; then
   EXPIRY_MONTH=01
  elif [ "${EXPIRY_MONTH}" == "Feb" ]; then
   EXPIRY_MONTH=02
  elif [ "${EXPIRY_MONTH}" == "Mar" ]; then
   EXPIRY_MONTH=03
  elif [ "${EXPIRY_MONTH}" == "Apr" ]; then
   EXPIRY_MONTH=04
  elif [ "${EXPIRY_MONTH}" == "May" ]; then
   EXPIRY_MONTH=05
  elif [ "${EXPIRY_MONTH}" == "Jun" ]; then
   EXPIRY_MONTH=06
  elif [ "${EXPIRY_MONTH}" == "Jul" ]; then
   EXPIRY_MONTH=07
  elif [ "${EXPIRY_MONTH}" == "Aug" ]; then
   EXPIRY_MONTH=08
  elif [ "${EXPIRY_MONTH}" == "Sep" ]; then
   EXPIRY_MONTH=09
  elif [ "${EXPIRY_MONTH}" == "Oct" ]; then
   EXPIRY_MONTH=10
  elif [ "${EXPIRY_MONTH}" == "Nov" ]; then
   EXPIRY_MONTH=11
  elif [ "${EXPIRY_MONTH}" == "Dec" ]; then
   EXPIRY_MONTH=12
  fi

  COMPARE=$(date -d "$EXPIRY_MONTH/$EXPIRY_DAY/$EXPIRY_YEAR 00:00:00" +"%s")
 fi
 
 SEC=$(expr ${COMPARE} - ${EPOCH})

 DAYS=$(expr ${SEC} / 86400)
 if [ "$DAYS" -lt 14 ]; then
  MSG="Warning: $HOST Renew Cert $DAYS days left."
  echo "$MSG"
  ERROR=yes
 elif [ "$DAYS" -lt 5 ]; then
  MSG="Error: $HOST Renew Cert $DAYS days left."
  echo "$MSG"
  ERROR=yes
 else
  echo "Ok: $HOST $DAYS days left."
 fi

 if [ "$ERROR" == "yes" ]; then
  ERROR_LIST="$ERROR_LIST $HOST"
 fi

done

if [ ! -z "$ERROR_LIST" ]; then
 echo "ERRORS: $ERROR_LIST"
 exit 1
fi
