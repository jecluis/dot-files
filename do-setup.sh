#!/bin/bash

warn() {
  echo -e "\e[1;33mwarn:\e[0m \e[1m$*\e[0m"
}

info() {
  echo -e "\e[1;96minfo:\e[0m \e[1m$*\e[0m"
}

error() {
  >&2 echo -e "\e[1;91merror:\e[0m \e[1m$*\e[0m"
}

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
    error "couldn't find ${vim_dir}"
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
    error "zshrc already exists at ${HOME}/.zshrc; no-op."
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
      error "${d} not detected; can't build tig"
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
    error "can't find executable tig at ${tig_build}/bin/tig"
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
        echo "moving $fn to ${fn}.old"
        mv $fn $fn.old
      done
      ln -fs ${src} ${dst}
    fi
  else
    ln -fs ${src} ${dst}
  fi
}

check_installed_script_exists() {
  name=$1

  bin_dir=${HOME}/bin
  path=${bin_dir}/${name}

  ( [[ -e "${path}" ]] || [[ -L "${path}" ]] ) && return 0
  return 1
}

setup_ceph() {
  cat <<EOF
Not doing much; in the future would be nice if this also set up a basic layout
for a ceph repo, basic dependencies and what not.

EOF

  scripts="ceph-do-cmake ceph-make ceph-vstart-kill"
  for s in $scripts; do
    echo "installing script ${s}"
    install_script ${cwd}/ceph/${s} ${s} || \
      ( echo "error installing script ${s}" ; exit 1 )
  done

  if check_installed_script_exists "local.do_cmake.sh"; then
    cat <<EOF

warning: local.do_cmake.sh in bin directory. We changed it to be
'ceph-do-cmake' instead, but we will not remove any existing files or
symlinks. We advise you to do it; you may find it in your bin directory.
EOF
  fi
}

setup_ovpn() {

info "Installing openvpn script to ${HOME}/bin"

  if [[ ! -e "/usr/sbin/openvpn" ]]; then
    error "openvpn not installed? please check and install if not."
    return 1
  fi

  ovpndir=${cwd}/openvpn
  ovpn=${ovpndir}/ovpn-connect
  ovpn_libdir=${ovpndir}/lib
  ovpn_helper=${ovpn_libdir}/ovpn-do-connect

  if [[ ! -d "${ovpndir}" ]]; then
    error "unable to find openvpn dir at '${ovpndir}'"
    return 1
  elif [[ ! -d "${ovpn_libdir}" ]]; then
    error "unable to find openvpn lib dir at '${ovpn_libdir}'"
    return 1
  elif [[ ! -e "${ovpn_helper}" ]]; then
    error "unable to find openvpn helper at '${ovpn_helper}'"
    return 1
  elif [[ ! -e "${ovpn}" ]]; then
    error "unable to find openvpn script at '${ovpn}'"
    return 1
  fi

  install_script ${ovpn} ovpn-connect || \
    ( error "installing script 'ovpn-connect'" ; exit 1 )

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
      error "unrecognized option '$1'"
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
