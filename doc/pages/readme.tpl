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
{{template "setup.tpl" . }}

# ssh container
{{template "config.tpl" (Config.Args "../alpine/containers/ssh.yaml" .)}}

# ssh template
{{template "config.tpl" (Config.Args "../alpine/templates/ssh.yaml" .)}}

# templates
{{template "templates.tpl" . }}
