#!/usr/bin/env bash

SERVER=$1
PASSW=$2 # the password that appears at the configs to be replaced by $NEW_PASSW
NEW_PASSW="YOURPASSWORDHERE"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 SERVER_NAME PASSW"
  exit 1
fi

rsync -avz --progress --exclude={'*.log','emby','jellyfin','qbittorrent','slskd','wallabag','prowlarr','sonarr','radarr','bazarr','qui'} $SERVER:~/server-dockers/docker-compose.yml $SERVER:/mnt/usb/configurations ./

# replace PASSW by NEW_PASSW (also in subdirs)
find . -type f -exec \
  sed -i "s/${PASSW//\//\\/}/${NEW_PASSW//\//\\/}/g" {} +
