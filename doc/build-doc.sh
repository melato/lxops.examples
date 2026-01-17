#!/bin/sh

# builds the README.md file, using readme.tpl
# uses gotemplate (not inluded here)

cd ..
gotemplate -files -o README.md -t readme.tpl doc/*.tpl
