# nginx template
The nginx image is an alpine image with the nginx package.

{{template "config.tpl" (Config.Args "alpine/templates/nginx.yaml" .)}}

# nginx container 
The nginx container configures nginx to read configuration files from /etc/opt/nginx

Since /etc/opt is mounted from a disk device, the files in /etc/opt/nginx persist across a container rebuild.

{{template "file.tpl" "alpine/nginx/config.cfg"}}
