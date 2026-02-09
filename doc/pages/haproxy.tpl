
{{template "config.tpl" (Config.Args "alpine/templates/haproxy.yaml" .)}}

{{template "config.tpl" (Config.Args "alpine/containers/haproxy.yaml" .)}}
