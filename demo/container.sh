#!/bin/sh

cd ../alpine/containers

# create and configure a container called ssh1
lxops launch -name ssh1 ssh.yaml

# create a file in one of its disk devices
incus shell ssh1 <<END
date > /opt/date
END

# rebuild the container
incus stop ssh1

# delete the container and its associated profile
lxops delete -name ssh1 ssh.yaml
# this is equivalent to:
#   incus delete ssh1
#   incus profile delete ssh1.lxops
# the devices are not deleted

## launch it again.  It will reuse the existing devices
lxops launch -name ssh1 ssh.yaml

# show that /opt/date is still there
incus exec ssh1 cat /opt/date

# you can create more containers like it
# lxops launch -name ssh2 ssh.yaml
