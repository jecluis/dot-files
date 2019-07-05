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

password-store setup: $(dirname $0)/run_setup.sh [opts]

Sets up a password store. Attempts to rely on a specific gpg keyring for
security purposes, and to allow easy accounting of keys used for the store,
instead of using the user's own gpg key. This can be configured though.

Also sets up the store to synchronize, over git, to a trusted repository.

Requires the gpg dir to be setup prior to running this script.


OPTIONS

  --keyid, -k <KEYID>   Use KEYID to initialize store.
  --autokey, -a         Attempt to find a key to initialize store.
  --debug, -d           Enable debug output.

DEPENDENCIES

  password-store


FILES and DIRECTORIES

  $(dirname $0)/pass.conf
    Configuration file, where we'll have the gpg dir to use, as well as other
    available options.

  ${HOME}/.password-store
    The store's location.

  ${HOME}/bin
    Where we'll be installing our several scripts. Of these, we include a
    'pass' wrapper for 'password-store', so we can control which gpg keyring
    to use.

  ${HOME}/.gnupg
    The default gpg keyring used if an alternative is not setup in 'pass.conf'.

EOF
}

do_help ;
