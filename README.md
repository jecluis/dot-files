DOT FILES
==========

Sets up helper scripts and configures environments for different pieces of
software. This repository will allow to synchronize the same setup over as
many machines as one has, without fears of missing something in one that may
be configured to taste on another.

As of the time of writing, we setup the following:

* ssh authorized keys
* tig
* vim
* zsh
* ceph scripts
* openvpn
* mutt
* password-store


For more information/help, run `do_setup.sh --help`.


ssh authorized keys
-------------------

These contain the authorized keys to access my machines. We want them spread
across the several machines so that we don't have to keep moving them around,
and possibly forget one here or there.


tig
---

By far our favorite cli git viewer, having it configured on any development
machine is a big requirement.


vim
---

Sets up vimrc and plugin goodies.


zsh
---

Sets up zsh to taste.


Ceph scripts
------------

Ensure that we have all our ceph scripts properly distributed. This not only
includes helper scripts, but also our ccache scripts tuned for compiling
multiple Ceph branches/releases. This would need a whole explanation by
itself, we just can't be bothered at this time.


openvpn
-------

Helper scripts to turn on/off our multiple vpns. Specific vpn configurations
are expected to live wherever that is, and we'll rely on systemd for
start/stop operations.

We rely on 'expect' to input the values upon request from systemd, and on
password-store to keep the values.

Passwords kept in the password store are not provided by this repository,
obviously.


mutt
----

Set up our mutt, mbsync, and msmtp. Whereas the configuration files for each
account are present, we will keep the passwords in password-store, and those
are obviously not provided.


password store
--------------

Set up a password store, with a custom gnupg dir where your keys should live
to encrypt/decrypt your passwords. Different utilities provided in this repo
will have different ways of storing their information in your password store.


EOF
