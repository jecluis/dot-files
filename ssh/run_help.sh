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

ssh setup: $(dirname $0)/run_setup.sh

Installs the ssh authorized keys. Nothing more.

FILES and DIRECTORIES

  ${HOME}/.ssh
    SSH directory; will be created and have modes adjusted if non-existant.
    Authorized keys will be written to this directory.

EOF
}

do_help ;
