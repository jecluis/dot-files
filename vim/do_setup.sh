#!/bin/bash
#
# Setup vim dot files 
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


do_setup() {
  setup_vim || return 1
  return 0
}


do_setup || exit 1
