#!/bin/bash
#
# Helper script for installation related operations 
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

install_script() {
  src=$1
  name=$2

  bin_dir=${HOME}/bin
  dst=${bin_dir}/${name}

  [[ ! -e "$bin_dir" ]] && mkdir $bin_dir
  if [[ -e "$dst" ]]; then
    sha_a=$(sha256sum ${src} | cut -f1 -d' ')
    sha_b=$(sha256sum ${dst} | cut -f1 -d ' ')

    if [[ "${sha_a}" != "${sha_b}" ]]; then
      for fn in $(ls -r ${dst}*); do
        warn "moving $fn to ${fn}.old"
        mv $fn $fn.old
      done
      ln -fs ${src} ${dst} 
    fi
  else
    ln -fs ${src} ${dst}
  fi
  # this can be a no-op, which technically still means we installed it
  bolden "  installed '${src}' to '${dst}'"
}

check_installed_script_exists() {
  name=$1

  bin_dir=${HOME}/bin
  path=${bin_dir}/${name}

  ( [[ -e "${path}" ]] || [[ -L "${path}" ]] ) && return 0
  return 1
}

