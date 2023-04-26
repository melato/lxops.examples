#!/bin/sh

if [ $# != 2 ]; then
    echo "usage: $0 <prefix> <name>"
    echo "example: $0 a base"
    exit 1
fi

DATE=`date +%Y%m%d-%H%M`

PREFIX=$1
name=$2
lxdops launch -name ${PREFIX}-${name}-$DATE ${name}.yaml || exit 1
lxdops property set ${name}-origin ${PREFIX}-${name}-$DATE/copy
lxdops property set ${name}-template ${PREFIX}-${name}-$DATE
