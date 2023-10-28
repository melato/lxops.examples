#!/bin/sh

if [ $# != 1 ]; then
    echo "usage: $0 <base-name>"
    echo "example: $0 custom"
    cat << END
- builds a container from a config file and then an image from this container.
- exports the image and any external filesystems into files in a directory.
- This exported directory serves as a template that can be used to create
- containers.

- Uses the config file <base-name>.yaml.
- The container/image name is composed from a prefix, the base-name, and a datetime string.
- publishes the container "copy" snapshot into an image with the same alias.
- exports this image to the ./images/<name> directory, creating it if necessary.
- Also exports any external devices to the same directory.
- sets the lxops property <base-name>-template to the name of the image
END
    exit 1
fi

DATE=`date +%Y%m%d-%H%M`
PREFIX=a
name=$1
INAME=${PREFIX}-${name}-$DATE
IMAGE_DIR=images/$INAME
mkdir -p $IMAGE_DIR

lxops launch -name $INAME ${name}.yaml || exit 1
lxops property set ${name}-template $INAME
lxops instance publish $INAME copy $INAME
lxops export -image -d $IMAGE_DIR -name $INAME ${name}.yaml
