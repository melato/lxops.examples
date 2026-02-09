#!/bin/sh

# create the ssh image
cd ../alpine/templates
./build.sh ssh

cd ../containers

# create the device templates
# this only needs to be done once for each image
# ssh.yaml uses (alpine-ssh-example) for both the image alias and the device template.
# The alpine-ssh-example property was created by build.sh above.
# first, find the value of the property
TEMPLATE=`lxops property get alpine-ssh-example`
# initialize the template devices, with the corresponding files from the image
lxops extract -name $TEMPLATE ssh.yaml
