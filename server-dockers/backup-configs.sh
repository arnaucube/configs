#!/usr/bin/env bash
#
# Usage:
# ./backup-configs.sh SERVER_NAME PASSW_TO_REPLACE

SERVER=$1
PASSW=$2 # the password that appears at the configs to be replaced by $NEW_PASSW
NEW_PASSW="YOURPASSWORDHERE"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 SERVER_NAME PASSW_TO_REPLACE"
  exit 1
fi

rsync -avz --progress --exclude={'*.log','emby','jellyfin','qbittorrent','slskd','wallabag','prowlarr','sonarr','radarr','bazarr','qui','libretranslate','swiparr','lingarr','lidarr','wireguard'} $SERVER:~/server-dockers/docker-compose.yml $SERVER:~/configurations ./

# replace PASSW by NEW_PASSW (also in subdirs)
find . -type f -exec \
  sed -i "s/${PASSW//\//\\/}/${NEW_PASSW//\//\\/}/g" {} +
