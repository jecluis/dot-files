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

ceph setup: $(dirname $0)/run_setup.sh

Sets up wrapper scripts for Ceph, and sets up a ccache infrastructure to
help with Ceph's compilation.

FILES and DIRECTORIES

  $(dirname $0)/ccache/ceph_ccache.conf
    Template for configuring defaults for ceph ccache infrastructure

  ${HOME}/.ceph_ccache
    Base directory where ccache information and configuration files for
    the ceph ccache infrastructure will be kept

  ${HOME}/bin/
    Where our scripts will be kept; advised to have this directory in the
    user's PATH.

EOF
}

do_help ;
