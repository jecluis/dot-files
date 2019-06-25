#!/bin/bash
#
# Setup our dot files
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

source common/print_helpers.sh

cd $(dirname $0)
cwd=$(pwd)

# setup vim
#
vim_dir=${cwd}/vim
vundle_dir=${vim_dir}/bundle/Vundle.vim

setup_vim() {
  if [[ -e "${HOME}/.vim" ]]; then
    info "${HOME}/.vim already exists; no-op."
    return 0
  fi 

  if [[ ! -e "${vim_dir}" ]]; then
    err "couldn't find ${vim_dir}"
    return 1
  fi

  [[ ! -e "${vim_dir}/bundle" ]] && mkdir ${vim_dir}/bundle

  if [[ ! -e "${vundle_dir}" ]]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ${vundle_dir} ||
      return 1
    info "cloned Vundle; please run ':PluginInstall' on vim startup"
  fi

  ln -fs ${vim_dir} ${HOME}/.vim
  return 0
}

# setup ssh
#
setup_ssh() {
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

# zsh / oh-my-zsh
#
zsh_dir=${cwd}/zsh
zsh_rc_tmpl=${zsh_dir}/zshrc.tmpl
zsh_omz_custom=${zsh_dir}/oh-my-zsh.tmpl/custom
zsh_omz_dir=${zsh_dir}/oh-my-zsh

setup_zsh() {

  if [[ -e "${HOME}/.zshrc" ]]; then
    err "zshrc already exists at ${HOME}/.zshrc; no-op."
    return 0
  fi

  if [[ ! -e "${zsh_omz_dir}" ]]; then
    info "cloning oh-my-zsh to ${zsh_omz_dir}"
    git clone https://github.com/robbyrussell/oh-my-zsh.git ${zsh_omz_dir} ||
      return 1

    if [[ ! -e "${HOME}/.oh-my-zsh" ]]; then
      info "creating ${HOME}/.oh-my-zsh symlink"
      ln -fs ${zsh_omz_dir} ${HOME}/.oh-my-zsh
    elif [[ -h "${HOME}/.oh-my.zsh" ]]; then
      warn "${HOME}/.oh-my-zsh symlink already exists; check if correct."
    fi
  fi

  if [[ -e "${zsh_dir}/zshrc" ]]; then
    warn "${zsh_dir}/zshrc already exists; clobbering."
    rm ${zsh_dir}/zshrc || return 1
  fi

  info "initializing ${zsh_dir}/zshrc"
  echo "export ZSH=${zsh_omz_dir}" >> ${zsh_dir}/zshrc
  echo "ZSH_CUSTOM=${zsh_omz_custom}" >> ${zsh_dir}/zshrc
  cat ${zsh_rc_tmpl} >> ${zsh_dir}/zshrc

  info "creating ${HOME}/.zshrc symlink"
  ln -fs ${zsh_dir}/zshrc ${HOME}/.zshrc

  return 0
}

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

}

setup_ceph() {
  info "Not doing much; in the future would be nice if this also set up a
basic layout for a ceph repo, basic dependencies and what not."

  # install scripts
  #
  info "installing ceph scripts"
  scripts="ceph-do-cmake ceph-make ceph-vstart-kill ceph-ccache"
  for s in $scripts; do
    install_script ${cwd}/ceph/${s} ${s} || \
      ( err "installing script ${s}" ; exit 1 )
  done

  if check_installed_script_exists "local.do_cmake.sh"; then
    warn "local.do_cmake.sh in bin directory. We changed it to be
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

}

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

  install_script ${ovpn} ovpn-connect || \
    ( err "installing script 'ovpn-connect'" ; exit 1 )

  info "installed 'ovpn-connect'"
}

do_vim=0
do_ssh=0
do_zsh=0
do_tig=0
do_ceph=0
do_ovpn=0

set_do_all() {
  do_vim=1
  do_ssh=1
  do_zsh=1
  do_tig=1
  do_ovpn=1
}

while [[ $# -gt 0 ]]; do

  case $1 in
    -h|--help|help)
      echo "usage: $0 [vim|ssh|zsh|tig|ceph|openvpn]"
      exit 0
      ;;
    vim) do_vim=1 ;;
    ssh) do_ssh=1 ;;
    zsh) do_zsh=1 ;;
    tig) do_tig=1 ;;
    ceph) do_ceph=1 ;;
    openvpn) do_ovpn=1 ;;
    *)
      err "unrecognized option '$1'"
      exit 1
      ;;
  esac
  shift
done

if [[ $do_vim -eq 0 ]] && [[ $do_ssh -eq 0 ]] &&
   [[ $do_zsh -eq 0 ]] && [[ $do_tig -eq 0 ]] &&
   [[ $do_ceph -eq 0 ]] && [[ $do_ovpn -eq 0 ]]; then
  set_do_all
fi


if [[ $do_vim -eq 1 ]]; then
  setup_vim || exit 1
fi

if [[ $do_ssh -eq 1 ]]; then
  setup_ssh || exit 1
fi

if [[ $do_zsh -eq 1 ]]; then
  setup_zsh || exit 1
fi

if [[ $do_tig -eq 1 ]]; then
  setup_tig
fi

if [[ $do_ceph -eq 1 ]]; then
  setup_ceph
fi

if [[ $do_ovpn -eq 1 ]]; then
  setup_ovpn
fi
