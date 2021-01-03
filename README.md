# google-drive-ocamlfuse - (servercontainers/google-drive-ocamlfuse) on alpine [x86 + arm]

I've created this container to mount google drive shares on my host system, without the need of installing this ocaml stuff.

It's pretty easy to use. Just start the container, look at the logs and visit the authentication link which will appear.
Give permissions to your google account and wait for the successfull mount.

Make sure to mount the config directory `/root/.gdfuse` so the token and config will persisted.

After that, just mount your volume mountpoint to the gdrive mountpoint inside the container like this: `/mnt/path/where/you/want/your/gdrive:/data:shared`.

It's loosely based on https://github.com/Patricol/dockerfiles-public/tree/master/alpine/gdrive.


## Changelogs

* 2021-01-03
    * added bash to fix scripts and startup
* 2020-11-20
    * removed unsupported arm 32 bit builds
* 2020-11-18
    * initial creation
    * up-to-date build
    * multiarch support

## Needed Options

* `device`
    * `/dev/fuse`

* `cap-add`
    * `mknod`
    * `sys_admin`

* `security-opt`
    * `apparmor:unconfined`

## Environment variables and defaults

*  __PUID__
    * optional
    * user id to map the google drive directory and files
    * default value: `0` (root)


*  __PGID__
    * optional
    * group id to map the google drive directory and files
    * default value: `0` (root)


*  __MOUNT\_OPTS__
    * optional
    * additional mount opts
    * no default value

## Samba integration

Since it was difficult to integrate with my samba system (permissions problem) I've enforced the user `root`.
After that it worked nicely.

You can use the folder also inside your Samba configuration (`servercontainers/samba`)

### Examples

#### docker env for: servercontainers/samba

```
SAMBA_VOLUME_CONFIG_gdrive: "[GDrive]; path = /shares/gdrive; valid users = alice; guest ok = no; read only = no; browseable = yes; force user = root; force group = root; admin users = root"
```

#### plain stanza for: smb.conf

```
[GDrive]
 path = /shares/gdrive
 valid users = alice
 guest ok = no
 read only = no
 browseable = yes
 force user = root
 force group = root
 admin users = root
```