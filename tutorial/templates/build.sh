#!/bin/sh

lxops launch -name ssh-template ssh.yaml
wait=5
echo "waiting $wait seconds for container installation scripts to complete"
incus stop ssh-template
incus snapshot create ssh-template copy
incus publish ssh-template/copy --alias alpine-ssh description=tutorial name=ssh-template os=alpine variant=ssh
