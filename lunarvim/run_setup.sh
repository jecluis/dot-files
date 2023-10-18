#!/bin/bash
#
# Setup lunarvim dot files 
# Copyright (C) 2023  Joao Eduardo Luis <joao@abysmo.io>
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

lvim_dir=${cwd}/lunarvim

check_exists() {

  if lvim --version >&/dev/null ; then
    info "lunarvim already found."
    return 1
  fi

}

check_deps() {
  deps=(
    "git"
    "make"
#    "pip" -- pip can take many forms, assume it exists
    "python3"
    "npm"
    "node"
    "cargo"
  )

  info "checking dependencies..."
  missing_dep=0
  for dep in ${deps[@]}; do
    if ! ${dep} --version >&/dev/null ; then
      err "error: missing dependency: ${dep}"
      missing_dep=1
    fi
  done

  if [[ ${missing_dep} -eq 0 ]]; then
    info "found required dependencies."
  else
    err "some dependencies are missing."
    return 1
  fi

  info "check for neovim installation..."
  if ! nvim --version >&/dev/null; then
    err "unable to find neo vim installation."
    err "please install neovim v0.9+ first."
    return 1
  fi

  ver=($(nvim --version | head -n 1 |& \
    sed -ne 's/NVIM v\([0-9]\+\).\([0-9]\+\).*/\1 \2'/p))

  if [[ ${ver[0]} -lt 0 ]]; then
    err "neovim v0.9+ required"
    return 1
  elif [[ ${ver[1]} -lt 9 ]]; then
    err "neovim v0.9+ required"
    return 1
  fi
  info "found neovim version v${ver[0]}.${ver[1]}+."

  info "requirements met!"
}

do_setup() {
  info "installing lunarvim from bundled installer..."

  LV_BRANCH='release-1.3/neovim-0.9' \
    bash ${lvim_dir}/dist/lunarvim_install.sh || return 1

  bin_dst="${HOME}/.local/bin/lvim"
  if [[ ! -e "${bin_dst}" ]]; then
    err "lvim not found at ${bin_dst} -- installation failed?"
    return 1
  fi

  cfg_dst="${HOME}/.config/lvim"
  if [[ ! -d "${cfg_dst}" ]]; then
    mkdir -p ${cfg_dst} || return 1
  fi
  cp ${lvim_dir}/config.lua ${cfg_dst}/config.lua || return 1

  info "lunarvim installed."
}

do_post_install() {

  info "checking for nerd fonts..."
  if ! fc-list | grep -iq 'nerd' ; then
    err "Nerd fonts not found!"
    err "Please go to https://www.nerdfonts.com/font-downloads and download a font."
    err "We recommend the DejaVuSansM Nerd Font."
    err ""
    err "Follow https://www.lunarvim.org/docs/installation/post-install for more information."
    return 0
  fi

  info "nerd font found, you are good to go!"
}

check_exists || exit 0
check_deps || exit 1
do_setup || exit 1
do_post_install || exit 1
