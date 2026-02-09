# Tips

## changing uids
Sometimes, a new OS release may cause a system user to be assigned a different uid (and gid) than before.
This may happen if the packages are installed in a different order in the image, or if some packages are added or omitted.
If the packages and their order are completely defined by my configuration files, I make sure that their order does not change.
But sometimes the package dependency changes in the distribution, causing a uid change.

This may cause an application to no longer work, because the application will have a new uid, but the data will have the old uid,
so the application may no longer have permission to alter the data.

I have encountered this situation several times.  I have used several strategies to address this problem.
As an example, assume that the application/user is nginx.

### Pre-create the application user
Create the nginx user with a hardcoded uid/gid, before installing the nginx package.

We can do this by creating the nginx user in one cloud-config file,
and installing the nginx package in another cloud-config file.
lxops applies cloud-config files in the order that they are listed.

When the nginx package is installed, it seems to check if the nginx user already exists and it does not try to create it again.

### chown the files
If I've already rebuilt the container, I simply find and chown all files from the old uid/gid to the new ones.

### Modify the application user
You can modify the uid/gid of the nginx user after the nginx package is installed.
But you may also need to chown any files that the package has already created for this user.
In the case of nginx, there are none, as all nginx configuration files are owned by root.

I no longer do this, because pre-creating the nginx user is a better solution.

