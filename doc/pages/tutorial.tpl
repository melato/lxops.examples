# create ssh template
{{template "config.tpl" (Config.Args "../tutorial/templates/ssh.yaml" .)}}

# ssh1 container
{{template "config.tpl" (Config.Args "../tutorial/containers/ssh1.yaml" .)}}
