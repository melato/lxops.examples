Most container lxops files include disk devices that are mounted in the container directories:
- /etc/opt
- /var/opt
- /opt
- /usr/local/bin
- /home
- /log
- /tmp

This means that whatever files are created in these directories will be preserved
when the container is deleted and then launched again.

/log and /tmp each have their own (zfs) filesystem.
The remaining devices share a filesystem.

Most of these directories are empty to begin with or may not even exist in the image.

/log is an exception.  Most containers won't work win an empty /log directory.

To populate the device directories, lxops configuration files use a *device-template* field.

The *lxops extract* command copies files from an image to template devices, which can then be specified in the *device-template* field.
For more information, see the lxops tutorial.

The locations of the filesystems are specified via lxops properties (fshost, fslog, fstmp),
so that they are not hardcoded in the configuration files.

The configuration file that specifies the filesystems and devices is this:

{{template "config.tpl" (Config.Args "device/standard.yaml" .).WithAnnotations.WithHeading "##"}}
