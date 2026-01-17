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

{{template "ssh.tpl" . }}
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
