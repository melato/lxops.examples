The Alpine /etc/motd file is generated from the configuration file below.
It contains the current date, the Alpine release version, and the container hostname.
The container hostname is expected to be related to the image that will be built from this container.

{{template "file.tpl" "alpine/base/motd.cfg"}}