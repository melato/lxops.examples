#!/bin/sh

cd ../alpine/containers

# assume container ssh1 is already running

# save one of the ssh public keys
KEY_FILE=/etc/ssh/ssh_host_ed25519_key.pub
OLD_KEY=`incus exec ssh1 cat $KEY_FILE`

# rebuild the container
# use incus commands to delete it
incus stop ssh1
lxops delete -name ssh1 ssh.yaml
lxops launch -name ssh1 ssh.yaml

# get the same ssh public key
NEW_KEY=`incus exec ssh1 cat $KEY_FILE`

echo ${KEY_FILE} before and after rebuild:
echo $OLD_KEY
echo $NEW_KEY
