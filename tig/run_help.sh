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

tig setup: $(dirname $0)/run_setup.sh

Clones, builds, and sets up tig.

DEPENDENCIES

  autoconf
  automake
  make
  gcc

FILES and DIRECTORIES

  ${HOME}/.tigrc
    Symlink to $(dirname $0)/tigrc

  $(dirname $0)/tigrc
    tig's configuration file

  $(dirname $0)/src
    Source repository, cloned from github.

  $(dirname $0)/build
    Finished build of tig's sources.

  ${HOME}/bin
    Where the 'tig' symlink will be created, pointing to our build directory's
    built binary.

EOF
}

do_help ;
