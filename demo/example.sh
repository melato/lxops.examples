#!/bin/sh

cd ../alpine/templates
./build.sh ssh

cd ../containers
TEMPLATE=`lxops property get alpine-ssh-example`
lxops extract -name $TEMPLATE ssh.yaml
lxops launch -name ssh1 ssh.yaml
