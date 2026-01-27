
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
