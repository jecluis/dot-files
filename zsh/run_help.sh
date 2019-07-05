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

zsh setup: $(dirname $0)/run_setup.sh

Sets up zsh and oh-my-zsh.

FILES and DIRECTORIES

  ${HOME}/.zshrc
    Symlink to $(dirname $0)/zshrc, which contains the zsh configuration.

  ${HOME}/.oh-my-zsh
    Symlink to $(dirname $0)/oh-my-zsh

  $(dirname $0)/oh-my-zsh
    Repository for oh-my-zsh, cloned directly from github.

EOF
}

do_help ;
