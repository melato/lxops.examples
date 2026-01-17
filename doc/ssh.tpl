## create an ssh image

{{template "file.tpl" "alpine/templates/ssh.yaml"}}

The first line, "#lxops-v1", identifies this file as an lxops file.

It uses the following fields:

**image** specifies the image to build the container from.
lxops replaces (VARIABLE) with the value of the VARIABLE property.

**cloud-config-files** is a list of cloud-config files to apply to the container.
Their paths may be absolute, or relative to the yaml file that includes them.

**ostype** specifies the container OS,
which is used to determine how to apply cloud-config files.
In particular, it is used to determine how to add packages and how to create users.

**description** is used in the image description (the first line only)

### build the image
```
cd alpine/templates
./build.sh ssh
```

the build.sh script calls a combination of *incus* and *lxops* commands

## create containers using the ssh image
First create template disk devices for these containers:
```
cd alpine/containers
image=`lxops property get alpine-ssh-example`
lxops extract -name $image ssh.yaml
```

*lxops extract* copies files from the image,
to template device directories, as specified in ssh.yaml.

Then, create one or more containers:

```
lxops launch -name s1 ssh.yaml
lxops launch -name s2 ssh.yaml
...
```

{{template "file.tpl" "alpine/containers/ssh.yaml"}}

This file has the same format as templates/ssh.yaml.

It has some additional fields:

**device-template** is the name of a container to copy disk devices from.
The container does not need to exist, but its non-root disk devices need to exist.

The template disk devices were created by the *lxops extract* command above.

ssh.yaml specifies the same value for *image* and *device-template*,
se we can use the same lxops property for both.

**include** has a list of other lxops files to include.

In this case, we include *../container.yaml*

{{template "file.tpl" "alpine/container.yaml"}}

container.yaml contains common configuration
that is included by several of our containers.

It includes several other yaml and cloud-config files.
You can read them to see what they do.

Some selected files are shown here:

{{template "file.tpl" "alpine/base/ssh_host_keys.cfg"}}

{{template "file.tpl" "device/standard.yaml"}}

This file specifies our *standard* disk devices.
These are disk devices that are attached to the container and are persisted.
If we delete the container the disk devices will not be deleted.
If we *lxops launch* the container again, it will have the same disk devices.

The *host* filesystem is defined in host.yaml.

We define 5 disk devices in it, that are mounted in the container at:
- /usr/local/bin
- /etc/opt
- /home
- /opt
- /var/opt

{{template "file.tpl" "device/host.yaml"}}

host.yaml specifies the *host* filesystem.

**pattern** specifies the name of the filesystem.

**(instance)** is a special lxops property that indicates the name of the container
that we're launching.

You can read about the remaining fields by running *lxops help config*

{{template "file.tpl" "device/log.yaml"}}

log.yaml specifies the /var/log disk device, in its own zfs filesystem.

{{template "file.tpl" "device/tmp.yaml"}}

tmp.yaml specifies the /tmp disk device, in its own zfs filesystem.
It has a *transient* property.  A *transient* filesystem is ignored
by certain lxops commands.  For more information, run: *lxops help filesystem*

##### (local_alpine)/container.yaml
This file contains custom configuration.
It is included only if the *local_alpine* property is defined.

demo/setup.sh sets *local_alpine* to demo/local_alpine (using an absolute path).

{{template "file.tpl" "demo/local_alpine/container.yaml"}}

This specifies a list of profiles which we want most of our containers to have.
and a user that will be created in each container.

demo/setup.sh generates a user.cfg file that creates
a user with similar as the current user, including the ssh authorized_keys.

We could have created the user in the image.
Creating it in the container gives us the flexibility to create different users
with the same image.
It doesn't take much time to create a user

Try using ssh to login to the container:
```
incus list s1
ssh {ip-address}
```

This should work, if "ssh localhost" works.

You can customize (local_alpine)/user.cfg to create any user, with whatever autorized_keys you want.

I typically create one ssh container per host with an ssh key, and put its public key
in (local_alpine)/user.cfg.  I can then ssh to any other container, using the first container.
