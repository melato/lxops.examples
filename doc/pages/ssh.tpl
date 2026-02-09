# SSH image
The ssh image provides the openssh server.  It is used as the base image for most other examples.
{{template "file.tpl" "alpine/templates/ssh.yaml"}}

# SSH container
{{template "file.tpl" "alpine/containers/ssh.yaml"}}

Because most other containers include ssh, the container configuration is stored in [container.yaml](container.md)

The container configuration for SSH does several things.
The things specific for ssh are:
## Disable ssh password authentication
{{template "file.tpl" "alpine/base/sshd.cfg"}}

## Preserve the ssh host keys
When rebuilding the container, the ssh host keys should not change.
If they change, then an ssh client will not recognize that it has connected to it before,
and it will ask the user before connecting again.


We preserve the ssh host keys by saving them in an external persistent directory.

If this directory does not exist, create it and copy the keys from /etc/ssh.

If the directory exists, copy the keys from this directory to /etc/ssh.

{{template "file.tpl" "alpine/base/ssh_host_keys.cfg"}}

The part of copying files to /etc/ssh is generalized so that any files in /etc/opt/etc/
are copied to /etc/

{{template "file.tpl" "alpine/base/etc.cfg"}}


Restart the ssh server as needed, to use the old keys.




