The tinyproxy container just has tinyproxy.

It is the only example container that does not use external disk devices.

To use it:
- enter a shell
- edit /etc/tinyproxy/tinyproxy.conf
- run: service tinyproxy start

{{template "config.tpl" (Config.Args "alpine/containers/tinyproxy.yaml" .)}}


