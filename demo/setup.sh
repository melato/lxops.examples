#!/bin/sh

if [ $# != 1 ]; then
cat <<END
usage: $0 ZFS-FILESYSTEM
example: $0 z/demo

set various lxops properties for use by examples
create a few customized configuration files in ./local
END
    exit 1
fi
    
set_properties() {
    config_dir="$HOME/.config/lxops"
    if [ -e "$config_dir" ]; then
        echo $config_dir already exists.  Please move it out of the way.
        exit 1
    fi

    properties_dir="$config_dir/properties.d"
    properties="$config_dir/properties.yaml"
    filesystems="$properties_dir/filesystems.yaml"
    mkdir -p $HOME/.config/lxops/properties.d
    touch "$properties"

    FSROOT="$1"
    if [ -z "$FSROOT" ]; then
        echo missing zfs filesystem
        exit 1
    fi
    if expr 1 = index "$FSROOT" / > /dev/null; then
        echo "zfs filesystem should not begin with a slash: $FSROOT"
        exit 1
    fi
    PWD=`pwd`
    cat > $filesystems <<END

fshost: "$FSROOT/host"
fslog: "$FSROOT/log"
fstmp: "$FSROOT/tmp"
local_alpine: $PWD/local_alpine
local_debian: $PWD/local_debian
END
    lxops property set alpine-image images:alpine/3.23

    mkdir -p local

    echo created $filesystems
    echo ${properties}:
    lxops property list
}

print_ssh_authorized_keys() {
    keys=$HOME/.ssh/authorized_keys
    if [ -e "$keys" ]; then
        sed 's/^/    - /' $keys
    fi
}

# create a cloud-config file that create a user with the same name, uid, and ssh authorized_keys as the current user,
# and with sudo permissions
create_user_cfg() {
    file=local/user.cfg
    if [ -e $file ]; then
        return
    fi
    uid=`id -u`
    name=`id -u -n`

    echo creating $file
cat << END > $file
#cloud-config
users:
- name: $name
  uid: $uid
  sudo: true
  groups: wheel,adm
  ssh_authorized_keys:
END

    print_ssh_authorized_keys >> $file
}

set_properties "$1"
create_user_cfg
