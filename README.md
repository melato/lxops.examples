This repository demonstrates how to use [lxdops](https://github.com/melato/lxdops)
to create LXD containers with attached filesystems.

The demo shows how to:
- create a template nginx container.
- create two working containers, cloned from the template.
- rebuild the containers

We will use alpine containers.
The configuration files are taken from my own production configuration,
except that I removed some configuration files for simplicity.

# resources used
lxdops uses "sudo zfs" commands to create, destroy, snapshot, and rollback filesystems.
The locations of these filesystems are use-defined by lxdops global properties and configuration files.
They should be different from the LXD storage filesystems.

lxdops also creates and deletes LXD containers and profiles.

The steps below should give you an idea of what it does.  It's best to try them on a new LXD installation.

# configure lxdops global properties
- select a base alpine image to use, typically the latest, for example images:alpine/3.17
- select a root ZFS filesystem to use, for example z/demo.
  zfs must be able to create this filesystem with sudo zfs create -p.

Run:

	lxdops property set alpine-image images:alpine/3.17
	lxdops property set fsroot z/demo

# create templates
We will create two templates, base and nginx.  The nginx template uses the base template.

	cd alpine/templates
	./template.sh a base
	./template.sh a nginx

To see the resources (filesystems, profiles, containers) that have been created so far, run:

	zfs list -r z/demo
	lxc list
	lxc profile list
	lxdops property list

	
template.sh adds the current date/time to the name of each template container it creates.
Therefore, when you rebuild the templates, the old templates will not be affected, and you can revert
to using the old templates.

lxdops does not have a distinction between templates and containers.	
Any container snapshot can be used as a template, to create other containers.

lxdops uses "lxc copy {template}/{snapshot} {new-container}" to launch containers,
but it also creates and attaches disk devices to a profile that it adds to the new container.

I've found it's best to mainly add packages in templates, applying minimal configuration, if any.
Then apply more configuration in containers, which can be created and tested more easily.
	
# create containers
	cd alpine/containers
	lxdops launch -name n1 nginx.yaml
	lxdops launch -name n2 nginx.yaml

# profiles
lxdops attaches disk devices to containers via a profile.
These profiles have the .lxdops suffix (configurable).
Take a look at one of these profiles:
	
	lxc profile show n1.lxdops	

lxdops configuration files have a profiles section where you can specify what profiles to attach to a container.

lxdops has "profile" subcommands that can be used to compare or re-apply profiles between a configuration file and a container:
	
	lxdops profile diff -name n1 nginx.yaml
	lxdops profile apply -name n1 nginx.yaml


# test nginx
	# find the ipv4 address of container n1 and run:
	curl http://{ip}/a.txt
	
	You should see the line "demo"

# change some files on a container
	lxc shell n1
	date > /var/opt/nginx/b.txt
	exit

	curl http://{ip}/b.txt
	
You should see a recent date.
	
# rebuild the containers	
	cd alpine/containers
	lxdops rebuild -name n1 nginx.yaml
	lxdops rebuild -name n1 nginx.yaml

# test a container again
	curl http://{ip}/b.txt

The container should have the same ip as before.
		
You should see the old data.

# rebuild the templates
repeat the "create templates" step.
It will create new templates, which you can then use to rebuild the containers.

# delete and re-launch a container
	cd alpine/containers
	lxc stop n1
	lxdops delete -name n1 nginx.yaml
The container is deleted, but the external filesystems still exist.
	lxdops launch -name n1 nginx.yaml
	
find the ip of container n1 (it will be different than before) and test again
	curl http://{ip}/b.txt
	
rebuild is the same as delete + launch, except that it preserves the container ip address.
It also preserves profiles, unless you use the -profiles flag.

# destroy a container and its filesystems
	cd alpine/containers
	lxc stop n1
	lxdops destroy -name n1 nginx.yaml
