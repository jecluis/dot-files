#!/bin/bash
#
# Setup tig repository and dot files 
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

tig_repo="https://github.com/jonas/tig.git"
tig_dir=${cwd}/tig
tig_rc=${tig_dir}/tigrc
tig_src=${tig_dir}/src
tig_build=${tig_src}/build

setup_tig() {

  deps="autoconf automake make gcc"
  for d in $deps; do
    if ! which ${d} ; then
      err "${d} not detected; can't build tig"
      return 1
    fi
  done

  if [[ ! -e "${tig_src}" ]]; then
    git clone ${tig_repo} ${tig_src} || return 1
  fi

  cd ${tig_src} || return 1
  ./autogen.sh || return 1
  ./configure --prefix=${tig_build} || return 1
  make -j 2 || return 1
  make -j 2 install
  cd ${cwd}

  if [[ ! -x "${tig_build}/bin/tig" ]]; then
    err "can't find executable tig at ${tig_build}/bin/tig"
    return 1
  fi

  info "creating symlink from ${HOME}/bin/tig to ${tig_build}/bin/tig"

  if [[ ! -d "${HOME}/bin" ]]; then
    info "creating ${HOME}/bin"
    mkdir ${HOME}/bin
  fi
  ln -fs ${tig_build}/bin/tig ${HOME}/bin/tig

  if [[ -e "${HOME}/.tigrc" ]]; then
    warn "${HOME}/.tigrc already exists; not creating symlink"
  else
    info "creating symlink from ${HOME}/.tigrc to ${tig_rc}"
    ln -fs ${tig_rc} ${HOME}/.tigrc
  fi

  return 0
}

do_setup() {
  setup_tig || return 1
  return 0
}

do_setup || exit 1
