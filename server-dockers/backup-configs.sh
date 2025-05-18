#!/usr/bin/env bash

SERVER=$1

if [ -z $SERVER ] ; then
	echo "missing 1st argument (SERVER)"
	exit 1
fi


rsync -avz --progress --exclude={'*.log','emby','jellyfin','qbittorrent','slskd','wallabag'} $SERVER:~/server-dockers/docker-compose.yml $SERVER:/mnt/usb/configurations ./
