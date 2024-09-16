#!/usr/bin/env bash

DEVICE=$1

if [ -z $DEVICE ] ; then
	echo "missing 1st argument (DEVICE), ie. the name of the device where the backup is being done"
	exit 1
fi

cp /etc/nixos/* ./nixos/
mv ./nixos/configuration.nix ./nixos/$DEVICE-configuration.nix
