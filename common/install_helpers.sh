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

install_file() {
  src=$1
  dst=$2

  info "installing '${src}' into '${dst}'"
  ( [[ -z "${src}" ]] || [[ -z "${dst}" ]] ) && \
    err "install_file requires two arguments; die." && exit 1

  sha_a=
  sha_b=

  if [[ -e "$dst" && ! -d "$dst" ]]; then
    sha_a=$(sha256sum ${src} | cut -f1 -d' ')
    sha_b=$(sha256sum ${dst} | cut -f1 -d ' ')
  fi

  if [[ ( -n "${sha_a}" && "${sha_a}" != "${sha_b}" ) || -e "${dst}" ]]; then
    backup_file "${dst}" "${dst}.bak" || return 1
  fi
  if ! ln -fs ${src} ${dst}; then
    err "unable to link file from '${dst}' to '${src}'"
    return 1
  fi
  # this can be a no-op, which technically still means we installed it
  bolden "  installed '${src}' to '${dst}'"
  return 0
}

install_bin_script() {
  src=$1
  name=$2
  ( [[ -z "$1" ]] || [[ -z "$2" ]] ) && \
    err "install_bin_script expects two arguments; die." && exit 1

  bin_dir=${HOME}/bin
  dst=${bin_dir}/${name}
  if [[ ! -e "$bin_dir" ]]; then
    mkdir -p ${bin_dir} || return 1
  fi

  install_file "${src}" "${dst}" || return 1
  return 0
}

install_script() {
  install_bin_script $* || return 1
  return 0
}

backup_file() {
  path=$1

  info "backing up '${path}'"
  mv --backup=numbered ${path} ${path}.bak || return 1
  return 0
}

backup_bin_script() {
  name=$1
  [[ -z "${name}" ]] && \
    err "backup_bin_script requires an argument; die." && exit 1

  path=${HOME}/bin/${name}
  backup_file ${path} || return 1
  return 0
}

check_file_installed() {
  path=$1
  [[ -z "${path}" ]] && \
    err "check_file_installed requires an argument; die." && exit 1
  ( [[ -f "${path}" ]] || [[ -L "${path}" ]] ) && return 0
  return 1
}

check_installed_script_exists() {
  name=$1

  bin_dir=${HOME}/bin
  path=${bin_dir}/${name}

  check_file_installed ${path} || return 1
  return 0
}

