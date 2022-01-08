# google-drive-ocamlfuse - (servercontainers/google-drive-ocamlfuse) on alpine [x86 + arm]

I've created this container to mount google drive shares on my host system, without the need of installing this ocaml stuff.

It's pretty easy to use. Just start the container, look at the logs and visit the authentication link which will appear.
Give permissions to your google account and wait for the successfull mount.

Make sure to mount the config directory `/root/.gdfuse` so the token and config will persisted.

After that, just mount your volume mountpoint to the gdrive mountpoint inside the container like this: `/mnt/path/where/you/want/your/gdrive:/data:shared`.

It's loosely based on https://github.com/Patricol/dockerfiles-public/tree/master/alpine/gdrive.


## Versioning

You'll find all images tagged like `a3.15.0-g0.7.23` which means `a<alpine version>-g<google-drive-ocamlfuse version>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

The `latest` version will be updated/released after I managed to test a new pinned version in my production environment.
This way I can easily find and fix bugs without affecting any users. It will result in a way more stable container.


## Changelogs

* 2022-01-08
    * better build script
    * improved readme
    * version pinning
    * custom user / group creation - for better mapping
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

### User Accounts (for usage with custom UID/GID)

* __GROUP\_groupname__
    * optional
    * value will be `gid`
    * example: `GROUP_devops=1500` will create group `devops` with id `1500`

* __ACCOUNT\_username__
    * optional
    * multiple variables/accounts possible
    * adds a new user account with the given username and the user id the env value
        * example `ACCOUNT_foo: 1001` will create user `foo` with uid `1001`
        * see `docker-compose.yml` user `foo` for an example how it's used/configured.

* __GROUPS\_username__
    * optional
    * additional groups for the user
    * to create groups look at `GROUP_groupname` or mount/inject /etc/groups file (can cause problems)
    * the `username` part must match to a specified `ACCOUNT_username` environment variable
    * one or more groups to add seperated by a `,`
    * example: `GROUPS_foo=musican,devops`

## Samba integration

Since it was difficult to integrate with my samba system (permissions problem) I've enforced the user `root`.
After that it worked nicely.

You can use the folder also inside your Samba configuration (`servercontainers/samba`)

### Examples

If you want to share the folder using samba, make sure your user has the same UID/GID.
Default is set to `root` which has UID: `0` and GID: `0`.

In order to use it properly with samba, you can enforce user and group `root` or use the UID/GID of the user you want to use it with.

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