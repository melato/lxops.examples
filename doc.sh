#!/bin/sh

# builds documentation files
# uses lxops-template

#lxops-template exec -D local_alpine=../doc/local_alpine -o README.md  -t readme.tpl doc/*.tpl
lxops-template build -c doc/build.yaml  -i doc/readme -o .
lxops-template build -c doc/build.yaml  -i doc/pages -o md
