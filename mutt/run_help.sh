#!/bin/bash
#
# Show help
# Copyright (C) 2019  Joao Eduardo Luis <joao@wipwd.org>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

do_help() {
  cat <<EOF

mutt setup: $(dirname $0)/run_setup.sh

Sets up neomutt, mbsync, msmtp, and notmuch. Access to a password store is
required to obtain passwords.

For this script to properly work, we require our mbsyncrc and msmtp's config
to be properly configured with user accounts and password commands. Otherwise,
the script will be unsuccessful.

FILES and DIRECTORIES

  $(dirname $0)/config
    Directory containing the directories (one or more) that shall be linked to
    ${HOME}/.config for each service we're setting up.

  $(dirname $0)/share
    Directory containing the directories (one or more) that shall be linked to
    ${HOME}/.local/share for each service we're setting up.

  $(dirname $0)/share/mutt
    Contains common files for neomutt's configuration.

  $(dirname $0)/config/mutt
    Contains muttrc and notmuch-config; also contains the accounts config to
    be used with muttrc.

  $(dirname $0)/config/mbsync
    Contains mbsync's configuration file.

  $(dirname $0)/config/msmtp
    Contains msmtp's configuration file.

  ${HOME}/.config/mutt
    Symlink to our config/mutt directory

  ${HOME}/.config/msmtp/config
    Symlink to our config/msmtp/config file

  ${HOME}/.msmtprc
    Symlink to ${HOME}/.config/msmtp/config

  ${HOME}/.mbsyncrc
    Symlink to our config/mbsync/mbsyncrc

  ${HOME}/.local/share/mail
    Contains maildirs for each account defined in config/mbsync's configuration

  ${HOME}/bin
    Contains the installed binaries, in the form of symlinks.

EOF
}

do_help ;
