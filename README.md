This repository contains lxops and cloud-config files for creating
selected incus templates and containers with [lxops](https://github.com/melato/lxops).

It is meant to serve as an example.

Most examples use alpine linux containers, because they are small and easy to work with.

# Be careful
lxops uses "sudo zfs ..." to create and destroy zfs filesystems.
These filesystems have parents specified in lxops properties, with names
that typically begin with "fs":  fshost, fslog, fstmp...

Run "lxops property list" to check that these properties do not point to any
filesystems that contain data not created by lxops.

It's best to experiment in a test system, as long as it has incus and zfs.
You can rent a suitable VPS for less than $0.01/hour.

# setup
The provided configuration files need certain lxops properties and files.
To initalize these, run:
```
cd demo
./setup.sh
```

The properties are in ~/.config/lxops/

To list them, run
```
lxops property list
```
Feel free to customize them.

Pay special attention to the fs* properties, as these specify
zfs filesystems that will be used by the examples.

## create an ssh image

We will use alpine/templates/ssh.yaml:
```
#lxops-v1
description: ssh server
ostype: alpine
image: (alpine-image)
cloud-config-files:
- ../packages/dhcpcd.cfg
- ../packages/openssh.cfg
- ../base/motd.cfg

```

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

#### alpine/containers/ssh.yaml
```
#lxops-v1
ostype: alpine
image: (alpine-ssh-example)
device-template: (alpine-ssh-example)
include:
- ../container.yaml

```

This file has the same format as templates/ssh.yaml.

It has some additional fields:

**device-template** is the name of a container to copy disk devices from.
The container does not need to exist, but its non-root disk devices need to exist.

The template disk devices were created by the *lxops extract* command above.

ssh.yaml specifies the same value for *image* and *device-template*,
se we can use the same lxops property for both.

**include** has a list of other lxops files to include.

In this case, we include *../container.yaml*

#### alpine/container.yaml
```
#lxops-v1
# common alpine container configuration
include:
- ../device/standard.yaml
- ../device/tmp.yaml
- (local_alpine)/container.yaml
cloud-config-files:
- base/nogetty.cfg
- base/etc.cfg
- base/sudo.cfg
- base/sshd.cfg
- base/ssh_host_keys.cfg

```

container.yaml contains common configuration for
that is included by several of our containers.

It includes several other yaml and cloud-config files.
You can read them to see what they do.

Some selected files are shown here:

##### alpine/base/ssh_host_keys.cfg
```
#cloud-config
# create new ssh host keys once, and copy them to a persisted directory,
# so that they can be restored when the container is re-launched.
# use with etc.cfg to preserve ssh host keys when rebuilding a container.
runcmd:
- |
    if [ ! -e /etc/opt/etc/ssh ]; then
      mkdir -p /etc/opt/etc/ssh
      rm -f /etc/ssh/ssh_host*
      service sshd restart
      cp /etc/ssh/ssh_host* /etc/opt/etc/ssh/
    else
      service sshd restart
    fi

```



##### device/standard.yaml
```
#lxops-v1
devices:
  bin:
    path: /usr/local/bin
    filesystem: host
  etc:
    path: /etc/opt
    filesystem: host
  home:
    path: /home
    filesystem: host
  opt:
    path: /opt
    filesystem: host
  var:
    path: /var/opt
    filesystem: host
include:
- host.yaml
- log.yaml

```

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

##### device/host.yaml
```
#lxops-v1
profile-pattern: (instance).lxops
device-owner: 1000000:1000000
filesystems:
  host:
    pattern: (fshost)/(instance)
    destroy: true

```

host.yaml specifies the *host* filesystem.

**pattern** specifies the name of the filesystem.

**(instance)** is a special lxops property that indicates the name of the container
that we're launching.

You can read about the remaining fields by running *lxops help config*

##### device/log.yaml
```
#lxops-v1
profile-pattern: (instance).lxops
device-owner: 1000000:1000000
filesystems:
  log:
    pattern: (fslog)/(instance)
    destroy: true
devices:
  log:
    path: /var/log
    filesystem: log
    dir: .

```

log.yaml specifies the /var/log disk device, in its own zfs filesystem.

##### device/tmp.yaml
```
#lxops-v1
profile-pattern: (instance).lxops
device-owner: 1000000:1000000
filesystems:
  tmp:
    pattern: (fstmp)/(instance)
    destroy: true
    transient: true
devices:
  tmp:
    path: /tmp
    filesystem: tmp
    dir: .

```

tmp.yaml specifies the /tmp disk device, in its own zfs filesystem.
It has a *transient* property.  A *transient* filesystem is ignored
by certain lxops commands.  For more information, run: *lxops help filesystem*

##### (local_alpine)/container.yaml
This file contains custom configuration.
It is included only if the *local_alpine* property is defined.

demo/setup.sh sets *local_alpine* to demo/local_alpine (using an absolute path).

##### demo/local_alpine/container.yaml
```
#lxops-v1
profiles:
- default
cloud-config-files:
- user.cfg

```

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

# templates/
The templates directory is for building images (also called templates).

Each template mainly installs packages.  It may start from another template.
Additional configuration is kept to a minimum, since it is easier to
do when launching containers from this image.

To create an image from configuration file NAME.yaml:
```
cd templates
./build.sh NAME
```

run "./build.sh" with no arguments to get a description of what it does.
