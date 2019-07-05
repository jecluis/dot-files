#!/bin/bash
#
# Setup Ceph dot files 
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

setup_ceph_ccache() {

  ceph_ccache_dir="${HOME}/.ceph_ccache"
  if [[ ! -e "${ceph_ccache_dir}" ]]; then
    mkdir -p ${ceph_ccache_dir}
  fi

  local_ccache_dir="${cwd}/ceph/ccache"
  if [[ ! -e "${local_ccache_dir}/ceph_ccache.conf" ]]; then
    return 1
  elif [[ ! -e "${ceph_ccache_dir}/ceph_ccache.conf" ]]; then
    cp ${local_ccache_dir}/ceph_ccache.conf ${ceph_ccache_dir}
  fi

  mkdir -p ${ceph_ccache_dir}/epochs
  mkdir -p ${ceph_ccache_dir}/ccache

  info "Wrote 'ceph_ccache.conf' to ${ceph_ccache_dir}.

You should check this file and adjust to your needs. The current values are
solely illustrative (and for the creator's benefit).

To take advantage of this, make sure to use the scripts provided, especially
'ceph-do-cmake' and 'ceph-make'. You can also easily issue commands to ccache
in the context of a given repository by running 'ceph-ccache'.

Enjoy!"

  return 0
}

setup_ceph() {
  info "We don't do much aside from setting up scripts and ccache; In the
future, we may even set up repositories, remotes, the whole nine yards."

  # install scripts
  #
  info "installing ceph scripts"
  scripts="ceph-do-cmake ceph-make ceph-vstart-kill ceph-ccache"
  for s in $scripts; do
    install_script ${cwd}/ceph/${s} ${s} || \
      ( err "installing script ${s}" ; return 1 )
  done

  if check_installed_script_exists "local.do_cmake.sh"; then
    warn "local.do_cmake.sh exists in bin directory. We changed it to be
'ceph-do-cmake' instead, but we will not remove any existing files or
symlinks. We advise you to do it; you may find it in your bin directory."
  fi

  # setup ceph ccache
  info "checking ceph ccache setup"
  if [[ ! -d "${cwd}/ceph/ccache" ]]; then
    warn "unable to find base ceph ccache directory; skipping setup"
  elif ! setup_ceph_ccache ; then
    err "setting up ceph ccache"
  fi

  return 0
}


do_setup() {
  setup_ceph || return 1
  return 0
}

do_setup || exit 1
