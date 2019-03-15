#!/bin/bash
set -euo pipefail
MSG=$1
URL=_SLACK_URL_
USER=_USER_
if [ -z "$URL" ] || [ -z "$MSG" ] || [ -z "$USER" ] || [ "$URL" == "_SLACK_URL_" ]; then
 echo "Error: var not set"
 exit 1
fi
curl -X POST --data-urlencode "payload={\"channel\": \"#alerts\", \"username\": \"webhookbot\", \"text\": \"$MSG bot $USER.\", \"icon_emoji\": \":ghost:\"}" $URL
