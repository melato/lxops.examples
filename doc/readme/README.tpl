This repository contains lxops and cloud-config files for creating
incus templates and containers with [lxops](https://github.com/melato/lxops),
for select applications.

For each application, there is an lxops file for creating an image and an lxops file for creating containers.

# Applications

- [Ssh](md/ssh.md)
- [Haproxy](md/haproxy.md)
- [Nginx](md/nginx.md)
- [Tinyproxy](md/tinyproxy.md)


# Common container configuration
[container.yaml](md/container.md), contains common configuration that is included
by most other example containers.  It is annotated in more detail than other configuration files.

# Containers
The container configuration files:
- Define external [disk devices](md/devices.md), to keep application data separate from the OS
- Perform application configuration, so that the application uses the external disk devices for further configuration or data.

Most examples use alpine linux containers, because they are small and easy to work with.

# Other Topics
- [Templates](md/templates.md)
- [Setup](md/setup.md)
- [Example](md/example.md)
- [Tips](md/tips.md)
