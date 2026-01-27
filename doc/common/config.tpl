{{- $path := .Path }}
{{- $properties := .Model }}
{{template "file.tpl" $path}}

{{- $config:= Config.ReadRaw $path}}

{{- $include := $config.Include}}
{{- $config = Config.Read $path $properties}}

{{- if len $include}}
**expanded:**
```
{{yaml $config}}
```
{{end}}

{{- if len $config.Filesystems}}
**filesystems**

Each filesystem is created using
```
   sudo zfs create $pattern
```
where $pattern is the value of the **pattern** field,
after variable substitution.
Each parenthesized expression is replaced with the value of the lxops property
that is in the parenthesis.

(instance) is replaced by the instance name.

If $pattern begins with '/', it is not treated as a zfs filesystem,
but as a directory, which is created using
```
   sudo mkdir -p $pattern
```

I hardly ever use non-zfs filesystems, so they are not tested as much.
zfs filesystems can be managed independently, snapshotted, rolled-back, synchronized, etc.

**disk devices**

Each device is a subdirectory of its corresponding filesystem,
except for a devices with *dir* set to '.', which is mapped to the filesystem directory itself,
without using a subdirectory.

**device-template**

If the device directory of a disk device already exists, it is left alone.
Otherwise, it is created using *sudo mkdir -p*, and its
content is initialized using:
```
   rsync -av $template_device_dir/ $device_dir/
```
- $device_dir is the full path of the device,
composed from the filesystem directory and the device subdirectory

- $template_device_dir is composed the same, way, except that the **(instance)**
variable in the filesystem pattern is replaced by the value of the *device-template*
field in the lxops config file.

**device-template initialization**

The *device-template* disk device directories can be initialized from the image,
using:
```
  lxops extract -name $template {{$path}}
```
where *$template* is the value of the *device-template* config field.

The **device-owner** field indicates the uid and gid of the root user in the container,
as seen by the host.
*lxops extract* copies the device files from the image, using *rsync*, and then
modifies the ownership of each file and directory by adding the *device-owner* values.

After the filesystems are created and the disk device directories populated,
a profile is created for the instance, using the profile name specified in the *profile-pattern* field.
This profile specifies the disk devices and is attached to the new instance.

{{end}}


{{- if $config.CloudConfigFiles}}
**cloud-config files**

After the container is launched and started,
the *cloud-config-files* are applied to it.
lxops waits for the container to have an ip address, before configuring it.

cloud-config-files may be included from other lxops config files.
Included files are applied first.

This config file applies the following cloud-config-files:

{{- $dir := File.Dir $path}}
{{range $i, $cpath := $config.CloudConfigFiles}}
{{template "file.tpl" (printf "%s" $cpath)}}
{{end}}
{{end}}

