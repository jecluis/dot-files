#!/bin/bash
#
# Setup zsh 
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

do_setup() {
  setup_zsh || return 1
  return 0
}


do_setup || exit 1
