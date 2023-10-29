lxops.examples demonstrates how to use [lxops](https://github.com/melato/lxops)
to create and configure LXD or Incus containers.
It is provided as a tutorial, and is subject to change.

# resources used

## LXD or Incus
These examples use an LXD or Incus installation.

Use a new test system, so that you don't accidentally ruin your existing system.

lxops creates and deletes LXD or Incus containers and profiles.  It also creates and destroys ZFS filesystems.

## ZFS
lxops uses "sudo zfs" commands to create, destroy, snapshot, and rollback filesystems that are attached as disk devices
to the containers it builds.

The locations of these filesystems are user-defined by lxops global properties and configuration files.
They should be different from the LXD or Incus storage filesystems.

The first example, example.yaml, does not use disk devices, so it can be used without ZFS.

## lxops
There is no lxops executable distributed.  You can build it from source using either
[lxops-lxd](https://github.com/melato/lxops_lxd)
or [lxops-incus](https://github.com/melato/lxops_incus)

Rename it to "lxops" (or create a symbolic link).

Use the appropriate lxops executable for your instance server.

For example, to build lxops_lxd:

	git clone https://github.com/melato/lxops_lxd
	cd lxops_lxd/main
	date > version
	go build lxops-lxd.go
	sudo cp lxops-lxd /usr/local/bin/lxops 

# run the examples
All the examples use alpine images.

# example.yaml
	cd alpine/containers
	lxops launch -name example1 example.yaml

This creates container "example1" and profile "example1.lxops".  The profile is empty in this example.

The example shows how to launch a container from an image, configure profiles and run cloud-config files.
It is uses a specific publicly-available image.


# nginx template and container
The nginx examples create a custom image, and use it to launch and rebuild containers with attached devices.
 
## configure lxops global properties
The nginx example uses two lxops properties, which you can set as follows:
- select a base alpine image to use, typically the latest, for example images:alpine/3.18
- select a root ZFS filesystem to use, for example z/demo
  zfs must be able to create this filesystem with: sudo zfs create -p.

Run:

	lxops property set alpine-image images:alpine/3.18
	lxops property set fsroot z/demo

## create nginx image
	cd alpine/templates
	./build.sh nginx

This:
- creates a log filesystem: <fsroot>/log/<container>

- creates a container with the log filesystem attached to /var/log
- configures the container by installing packages
- makes a snapshot of the container and publishes the snapshot as an image
- exports the image to disk in ./images/<container>/
- exports the log filesystem as a tar.gz file
- sets the lxops propety "nginx-template" to the name of the image

The container and the image have a demo- prefix and a datetime suffix.

## launch nginx container
	cd alpine/containers
	lxops launch -name n1 nginx.yaml

This:
- creates zfs filesystems <fsroot>/host/n1, <fsroot>/log/n1, <fsroot>/tmp/n1,
  as specified in nginx.yaml
- creates subdirectories in these filesystems
- copies files from the template (in this case /var/log/)
- adds the subdirectories as disk devices to a new profile named n1.lxops
- creates a container named "n1" with the specified profiles and the n1.lxops profile
- configures the container by running cloud-config files

The container can be tested using
	curl http://<ip>/a.txt

You start a shell in the container and make changes to /var/opt/nginx and /etc/opt/nginx
These changes will be preserved when you delete and relaunch the container.

## create new nginx image
We will create a new nginx image, as we did before, so that we demonstrate rebuilding the container with a new image:

	cd alpine/templates
	./build.sh nginx

The name used for the image includes a timestamp in it, so the old image and the new image can coexist.
The nginx-template property is set to the new image.
If the new image doesn't work, you can set nginx-template back to the old image.

## launch a test container with the new image
	cd alpine/containers
	lxops launch -name n2 nginx.yaml

Once you test n2, you can delete it:

	cd alpine/containers
	lxc stop n2
	# or incus stop n2
	lxops destroy -name n2 nginx.yaml

## rebuild n1 with the new image
	cd alpine/containers
	lxops rebuild -name n1 nginx.yaml

This will relaunch the container with the new image and the old devices. 
Because of the way the container is configured, the nginx configuration and website files will be preserved.

## delete the old template
	cd alpine/templates
	lxops destroy -name <old-image> nginx.yaml

# delete vs destroy

The delete command deletes the container and its profile, but not the attached filesystems.
The destroy command also destroys the filesystems specified in .yaml file.
The container must be stopped already.

	cd alpine/containers
	lxops delete -name n1 nginx.yaml
	lxops destroy -name n1 nginx.yaml