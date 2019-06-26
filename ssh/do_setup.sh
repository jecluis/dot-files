#!/bin/bash
#
# Setup SSH dot files 
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

[[ ! -d "$(pwd)/.git" ]] && \
  >&2 echo "error: must run from the repository's root!" && \
  exit 1

source common/print_helpers.sh
source common/install_helpers.sh

cwd=$(pwd)

do_setup() {

  if [[ ! -e "${HOME}/.ssh" ]]; then
    mkdir -m 0700 ${HOME}/.ssh
  fi

  auth_keys=${HOME}/.ssh/authorized_keys
  if [[ -e "${auth_keys}" ]]; then
    warn "${auth_keys} already exists; append may result in duplicates."
  fi

  cat ${cwd}/ssh/authorized_keys >> ${auth_keys}

  return 0
}


do_setup || exit 1
