# Images
The templates directory is for building images (also called templates).

Images are created, using incus tools for publishing an iamge from a container.

Therefore each template lxops configuration file launches and configures a container.

Each template mainly installs packages. It may start from another template.
It also generates an [/etc/motd](md/motd.md) file containing version information.
Additional configuration is kept to a minimum, since it is easier to refine the configuration by launching containers,
than building images.

There is a build script provided to launch and configure a template container,
and then publish it as an image.

To create an image from configuration file NAME.yaml:

cd templates
./build.sh NAME

run "./build.sh" with no arguments to get a description of what it does.

