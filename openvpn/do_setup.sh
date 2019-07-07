#!/bin/bash
#
# Setup VPN dot files 
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

setup_ovpn() {

info "Installing openvpn script to ${HOME}/bin"

  if [[ ! -e "/usr/sbin/openvpn" ]]; then
    err "openvpn not installed? please check and install if not."
    return 1
  fi

  if ! which pass 2>/dev/null ; then
    err "'pass' not installed; please install 'password-store'"
    return 1
  fi

  if ! pass show >&/dev/null ; then
    err "unable to obtain password store; maybe needs 'pass init'?"
    return 1
  fi

  ovpndir=${cwd}/openvpn
  ovpn=${ovpndir}/ovpn-connect
  ovpn_libdir=${ovpndir}/lib
  ovpn_helper=${ovpn_libdir}/ovpn-do-connect

  if [[ ! -d "${ovpndir}" ]]; then
    err "unable to find openvpn dir at '${ovpndir}'"
    return 1
  elif [[ ! -d "${ovpn_libdir}" ]]; then
    err "unable to find openvpn lib dir at '${ovpn_libdir}'"
    return 1
  elif [[ ! -e "${ovpn_helper}" ]]; then
    err "unable to find openvpn helper at '${ovpn_helper}'"
    return 1
  elif [[ ! -e "${ovpn}" ]]; then
    err "unable to find openvpn script at '${ovpn}'"
    return 1
  fi

  for script in ovpn-connect ovpn-init ; do
    install_script ${ovpndir}/${script} ${script} || \
      ( err "installing script '${script}'" ; return 1 )
    info "installed '${script}'"
  done

  return 0
}

do_setup() {
  setup_ovpn || return 1
  return 0
}

do_setup || exit 1
