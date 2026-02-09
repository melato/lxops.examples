{{template "config.tpl" (Config.Args "alpine/container.yaml" .).WithHeading "##"}}

## Customization

container.yaml uses the *local_alpine* property to conditionally include custom container configuration.

There is nothing special about *local_alpine*.  Any name can be used.
If an *include* or a *cloud-config-files* path references a property
that does not exist, the path will not be used at all.

This serves as conditional inclusion.

For documentation purposes, we define an *local_alpine* property that points
to a file that creates a "demo" user.
You can use the same technique to create a user with custom authorized_keys.

The [setup](setup.md) script generates a more realistic user configuration file.
You can create your own setup script to generate custom configuration.