# Example
This shows how to create an ssh image and an ssh container, from beginning to end.

This creates and deletes a container called "ssh1".  Make sure you don't have such a container.

## Setup
First, run [setup](setup.md) to initialize lxops properties, if you haven't done so already.

## Create an image and device templates
{{template "file.tpl" "demo/image.sh"}}

## Create and rebuild a container
{{template "file.tpl" "demo/container.sh"}}

## Rebuild the container again, and check that an ssh host key is preserved
{{template "file.tpl" "demo/rebuild.sh"}}
