#!/bin/sh

# create the (alpine-ssh-example) image
cd ../alpine/templates
./build.sh ssh

cd ../containers

# create the (alpine-ssh-example) device templates
# this only needs to be done once for each image
# ssh.yaml uses (alpine-ssh-example) for both the image and the device template.
# first, find the value of the property
TEMPLATE=`lxops property get alpine-ssh-example`
# initialize the template devices, with the corresponding files from the image
lxops extract -name $TEMPLATE ssh.yaml

