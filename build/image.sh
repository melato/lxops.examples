#!/bin/sh

if [ -z "$LXOPS_SUFFIX" ]; then
  LXOPS_SUFFIX="example"
fi
SNAPSHOT=copy
DATE=`date +%Y%m%d-%H%M`
if [ $# != 2 ]; then
    cat << END
usage: $0 <prefix> <base-name>
example: $0 alpine ssh

- builds a container from a config file, using a timestamped container name
- stops the container and creates a snapshot ($SNAPSHOT)
- publishes the container to an image
- exports the image into a directory
- sets the lxops property <prefix>-<base-name>-$LXOPS_SUFFIX to the name of the image

- Uses the config file <base-name>.yaml.
- The image name is <prefix>-<base-name>-$DATE using the current datetime.
- The container name is the same as the image name
- if the LXOPS_IMAGES_DIR environment variable is set,
  it creates sub-directory \$LXOPS_IMAGES_DIR/<image-name> and exports the image there.
- The config file for images should not have any external devices,
  so that the resulting image can be used as a normal incus image
  with a complete root filesystem.
  If you want to launch a container with attached disk devices from the image,
  you can extract these devices from the image using "lxops extract".

Environment variables:
  LXOPS_SUFFIX:  a suffix to use for image names.  defaults to "$LXOPS_SUFFIX"
  LXOPS_IMAGES_DIR: a directory to export images to.
END
    exit 1
fi

prefix=$1
name=$2
iname=${prefix}-${name}-$DATE

cat << END
config file:   $name.yaml
instance name: $iname
image name:    $iname
END

lxops launch -name $iname ${name}.yaml || exit 1

wait=5
echo "waiting $wait seconds for container installation scripts to complete"
sleep $wait
incus stop $iname
incus snapshot create $iname $SNAPSHOT
lxops property set $prefix-${name}-$LXOPS_SUFFIX $iname
lxops publish \
  -c "$name.yaml" \
  -serial $DATE \
  -name $iname \
  $iname/$SNAPSHOT

if [ ! -z "$LXOPS_IMAGES_DIR" ]; then
    image_dir=$LXOPS_IMAGES_DIR/$iname
    mkdir -p $image_dir
    lxops export -image -d $image_dir -name $iname ${name}.yaml
    echo "exported image to $image_dir"
fi

cat <<END
To delete the container, run:
  lxops delete -name $iname ${name}.yaml
END
