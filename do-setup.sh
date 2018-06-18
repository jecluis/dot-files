#!/bin/bash

cd $(dirname $0)
cwd=$(pwd)

# setup vim
#
vim_dir=${cwd}/vim

if [[ -e "${HOME}/.vim" ]]; then
  echo "error: ${HOME}/.vim already exists; do something about it and rerun"
  exit 1
fi

if [[ ! -e "${vim_dir}" ]]; then
  echo "error: couldn't find $vim_dir"
  exit 1
fi

[[ ! -e "${vim_dir}/bundle" ]] && mkdir ${vim_dir}/bundle

vundle_dir=${vim_dir}/bundle/Vundle.vim
if [[ ! -e "${vundle_dir}" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ${vundle_dir} || exit 1

  echo "info: cloned Vundle; please run ':PluginInstall' on vim startup"
fi

ln -fs ${vim_dir} ${HOME}/.vim

# ssh
#
if [[ ! -e "${HOME}/.ssh" ]]; then
  mkdir -m 0700 ${HOME}/.ssh
fi

if [[ -e "${HOME}/.ssh/authorized_keys" ]]; then
  echo "warn: authorized_keys already exists; append may result in duplicates."
fi
cat ${cwd}/ssh/authorized_keys >> ${HOME}/.ssh/authorized_keys

# zsh / oh-my-zsh
#
zsh_dir=${cwd}/zsh
zsh_rc_tmpl=${zsh_dir}/zshrc.tmpl
zsh_omz_custom=${zsh_dir}/oh-my-zsh.tmpl/custom
zsh_omz_dir=${zsh_dir}/oh-my-zsh

if [[ ! -e "${zsh_omz_dir}" ]]; then
  echo "info: cloning oh-my-zsh to ${zsh_omz_dir}"
  git clone https://github.com/robbyrussell/oh-my-zsh.git ${zsh_omz_dir} ||
    exit 1
  echo "info: creating ${HOME}/.oh-my-zsh symlink"
  ln -fs ${zsh_omz_dir} ${HOME}/.oh-my-zsh
fi

if [[ ! -e "${HOME}/.zshrc" ]]; then
  echo "info: initializing ${cwd}/zshrc"
  echo "export ZSH=${zsh_omz_dir}" >> ${zsh_dir}/zshrc
  echo "ZSH_CUSTOM=${zsh_omz_custom}" >> ${zsh_dir}/zshrc
  cat ${zsh_rc_tmpl} >> ${zsh_dir}/zshrc

  echo "info: creating ${HOME}/.zshrc symlink"
  ln -fs ${zsh_dir}/zshrc ${HOME}/.zshrc
else
  echo "warn: ${HOME}/.zshrc already exists; no-op."
fi

