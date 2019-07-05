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

vim setup: $(dirname $0)/run_setup.sh

Sets up vim installation, both the vimrc and the Vundle repo and scripts.

FILES and DIRECTORIES

  ${HOME}/.vim
    The directory where all things vim will be kept; if it already exists, no
    action will be taken.

  ${HOME}/.vim/bundle/Vundle.vim
    Where the Vundle repository will be set up.

EOF
}

do_help ;
