#!/bin/sh

# builds the README.md file, using readme.tpl
# uses gotemplate (not inluded here)

cd ..
gotemplate -files -t doc/readme.tpl -o README.md
