#!/bin/bash
#
# Show help
# Copyright (C) 2023  Joao Eduardo Luis <joao@abysmo.io>
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

lunarvim setup: $(dirname $0)/run_setup.sh

Sets up lunarvim installation.

FILES and DIRECTORIES

  ${HOME}/.config/lvim
    The lunarvim configuration files will be kept.

  ${HOME}/.local/share/lvim
    Where some lunarvim files will be kept.

  ${HOME}/.local/share/lunarvim
    Where yet more lunarvim files will be kept.

EOF
}

do_help ;
