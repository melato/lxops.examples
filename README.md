lxops.examples demonstrates how to use [lxops](https://github.com/melato/lxops)
to create and configure LXD or Incus containers

# resources used

## LXD or Incus
These examples use an LXD or Incus installation.

Use a new LXD/Incus installation, so that you don't accidentally ruin your existing system.

lxops creates and deletes LXD/Incus containers and profiles.  It also creates and destroys ZFS filesystems.

## ZFS
lxops uses "sudo zfs" commands to create, destroy, snapshot, and rollback filesystems that are attached as disk devices
to the containers it builds.

The locations of these filesystems are user-defined by lxops global properties and configuration files.
They should be different from the LXD/Incus storage filesystems.

The first example, example.yaml, does not use disk devices, so it can be used without ZFS.

## lxops
There is no lxops executable distributed.  You can build either
[lxops-lxd](https://github.com/melato/lxops_lxd)
or [lxops-incus](https://github.com/melato/lxops_incus)
from source, and then rename it to "lxops" (or create a symbolic link).

Use the appropriate lxops executable for your instance server.

# run the examples
All the examples use alpine images.

# example.yaml
	cd alpine/containers
	lxops launch -name example1 example.yaml

This example shows how to launch a container from an image, configure profiles and run cloud-config files.
It does not create any disk devices for the container.
It does not use any lxops properties.  It is hardcoded to use a specific publicly-available image.

# configure lxops global properties
The remaining examples use two lxops properties, which you can set as follows:
- select a base alpine image to use, typically the latest, for example images:alpine/3.18
- select a root ZFS filesystem to use, for example z/demo.
  zfs must be able to create this filesystem with: sudo zfs create -p.

Run:

	lxops property set alpine-image images:alpine/3.18
	lxops property set fsroot z/demo


# launch devices.yaml
	cd alpine/containers
	lxops launch -name d1 devices.yaml

This example:
- creates zfs filesystems z/demo/host/d1, z/demo/log/d1, z/demo/tmp/d1
- creates subdirectories in these filesystems
- sets the ownership of these subdirectories so they are seen as owned by root when attached to a container
- adds the subdirectories as disk devices to a new profile named d1.lxops
- creates a container named "d1" with the specified profiles and the d1.lxops profile
- configures the container by running cloud-config files

# rebuild devices.yaml
	lxops rebuild -name d1 devices.yaml

This example:
- retrieves the profiles attached to the container and the network hwaddr of the container
- stops and deletes the container
- rebuilds the d1.lxops profile
- launches the container again, with the previous profiles and the previous hwaddr
  The goal of preserving hwaddr is to preserve the container ip addresses, if they are provided via dhcp.
  There are flags to skip this part, if the ip addresses are statically provided separately (via profiles).

In essence, this updates the guest OS of the container, while preserving data in attached devices, and configuration (profiles, ip addresses).

# delete d1 devices.yaml
	lxops delete -name d1 devices.yaml
	
This deletes container d1 and profile d1.lxops.  It does not delete or destroy the attached devices.
The deleted container can be launched again with the existing devices.

# destroy d1 devices.yaml
	lxops destroy -name d1 devices.yaml
	
This deletes and destroys everything associated with container d1:
- It deletes container d1
- It deletes profile d1.lxops
- It destroys the zfs filesystems that were attached to the container

# create custom image/template
	cd alpine/templates
	./build-image.sh custom
	
This example:
- creates a container, with a timestamp in its name
- attaches a newly created ZFS filesystem to the /var/log directory of the container
- configures the container with cloud-config files
- stops it
- makes a snapshot
- publishes this snapshot as an image with the same alias as the container name
- exports the image to a file, so it can be imported to another system
- creates a tar.gz archive of /var/log, so it can be imported to another system
- sets the custom-template property to the name of the container

# create a container from the custom template
	cd alpine/containers
	lxops launch -name c1 custom.yaml

This example performs similar steps as the devices.yaml example above.
Additionally, it copies files from the log filesystem that was created when the custom template was created.
