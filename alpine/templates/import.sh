#!/bin/sh

IMAGES_DIR=./images

NAMES="$*"
if [ "$NAMES" = "" ]; then
cat << END
imports an image and any external devices, exported from build-image.sh
- parses out base-name from the import name, by removing the prefix and the timestamp.
- imports the image into the image server
- extracts any external filesystems
  - the extracted filesystems are as if they were created
    from the config file for a container that has the template name
  - creates ZFS filesystems
  - untars the exported tar files into the new ZFS filesystems

images must be imported in dependency order
available images:
END
  ls -1 $IMAGES_DIR
  exit 0
fi

for name in $NAMES; do
  echo importing $name
  BASE=`echo $name | sed 's/^.-//' | sed 's/-.*//'`
  lxops import -image -d $IMAGES_DIR/$name -name $name $BASE.yaml
  lxops property set ${BASE}-template $name
done
