#!/bin/bash
#
# Setup neomutt dot files 
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
debug() {
  echo -e "${color_bold}debug/${FUNCNAME[1]}${color_reset}: $*"
}

install_mutt_config() {
  func="${FUNCNAME[0]}"
  user_conf="${HOME}/.config"

  our_conf="${cwd}/mutt/config/mutt"
  if [[ ! -e "${our_conf}" ]]; then
    err "$func: could not find our config directory at '${our_conf}'; die."
    exit 1
  fi

  if [[ ! -d "${user_conf}" ]]; then
    info "$func: creating user config dir at '${user_conf}'"
    mkdir -p ${user_conf} || return 1

  elif [[ -e "${user_conf}/mutt" ]]; then
    warn "found mutt at '${user_conf}'; backup."
    backup_file "${user_conf}/mutt" || return 1
  fi
  info "installing mutt directory link at '${user_conf}/mutt'"
  install_file "${our_conf}" "${user_conf}/mutt" || exit 1

  return 0
}

install_mutt_directory() {
  func="${FUNCNAME[0]}"
  what="${1}"
  our_what="${2}"
  theirs_what="${3}"

  [[ -z "${what}" || -z "${our_what}" || -z "${theirs_what}" ]] && \
    err "$func: requires 3 arguments; die." && exit 1

  if [[ ! -e "${our_what}" ]]; then
    return 0 # we don't have it, so no point in setting it up
  elif [[ ! -d "${our_what}" ]]; then
    err "$func: could not find directory for '${what}' at '${our_what}'; die."
    exit 1
  fi

  debug "running for '${what}', ours '${ours}', theirs '${theirs}'"

  theirs_parentdir="$(dirname ${theirs})"
  if [[ ! -d "${theirs_parentdir}" ]]; then
    info "$func: creating user '${what}' parent dir at '${theirs_parentdir}'"
    mkdir -p ${theirs_parentdir} || return 1

  elif [[ -e "${theirs_what}" ]]; then
    warn "found '${what}' at '${theirs_what}'; backup."
    backup_file "${theirs_what}" || return 1
  fi
  info "installing '${what}' directory link at '${theirs_what}'"
  install_file "${our_what}" "${theirs_what}" || exit 1
  info "installed '${what}' at '${theirs_what}'"
}

install_mutt() {
  user_share="${HOME}/.share"
  user_local="${HOME}/.local"

  what=(config local cache)
  for w in ${what[*]}; do
    ours=${cwd}/mutt/${w}/mutt
    theirs=${HOME}/.${w}/mutt

    debug "installing '${w}', ours '${ours}', theirs '${theirs}'"

    [[ ! -e "${ours}" ]] && continue # skip if we don't have it.
    install_mutt_directory "${w}" "${ours}" "${theirs}" || return 1
  done

  if [[ -e "${cwd}/mutt/share" ]]; then
    ours="${cwd}/mutt/share/mutt"
    theirs="${HOME}/.local/share/mutt"
    w="share"

    install_mutt_directory "${w}" "${ours}" "${theirs}" || return 1
  fi
  return 0
}

create_maildirs() {
  func="${FUNCNAME[0]}"

  file="${cwd}/mutt/config/mbsync/mbsyncrc"
  maildirs=($(cat $file | grep '^[ ]*Path' | sed 's/^[ ]*Path[ ]\+//'))

  [[ ! -e "${file}" || ${#maildirs[*]} -eq 0 ]] && \
    err "unable to create maildirs; die." && exit 1

  for d in ${maildirs[*]}; do
    md=${HOME}/$(echo ${d} | sed 's/~\///')
    if [[ ! -e "${md}" ]]; then
      info "creating maildir at '${md}'"
      mkdir -p ${md} || return 1
    fi
  done
  return 0
}

check_passwords() {
  info "checking passwords"
  file="${cwd}/mutt/config/mbsync/mbsyncrc"

  passwd=()
  IFS=$'\n'
  for line in $(cat $file | grep '^[ ]*PassCmd' |\
    sed 's/^[ ]*PassCmd[ ]\+//' | sed 's/"//g'); do
    passwd=(${passwd[*]} "$line")
  done

  [[ ${#passwd} -eq 0 ]] && \
    err "unable to find passwords in file" && return 1

  for cmd in ${passwd[*]}; do
    cmd=$(echo $cmd | sed 's/"//g')
    if [[ ! $cmd =~ 'pass ' ]]; then
      warn "found potentially plain-text password in '$file' ($cmd)"
      continue
    fi
    echo ">>> $cmd"
    if ! $cmd >&/dev/null ; then
      pass=$(echo "$cmd" | sed 's/^[ ]*pass[ ]\+//')
      warn "invalid password '${pass}'"
    fi
  done
  return 0
}

install_mbsync() {
  func="${FUNCNAME[0]}"
  info "configuring mbsync"

  theirs="${HOME}/.mbsyncrc"
  ours="${cwd}/mutt/config/mbsync/mbsyncrc"

  if check_file_installed "${theirs}"; then
    warn "backing up '${theirs}'"
    backup_file ${theirs} || return 1
  fi
  info "installing mbsyncrc to '${theirs}'"
  install_file "${ours}" "${theirs}" || return 1

  create_maildirs || return 1
  # passwd checking keeps borking and I'm tired of trying to make it work.
  # FIXME: mutt password checking
#  check_passwords || return 1

  return 0
}

install_msmtp() {
  func="${FUNCNAME[0]}"
  info "configuring msmtp"

  theirs="${HOME}/.config/msmtp"
  ours="${cwd}/mutt/config/msmtp"

  if check_file_installed "${theirs}"; then
    warn "backing up '${theirs}'"
    backup_file "${theirs}" || return 1
  fi
  info "installing mbsync to '${theirs}'"
  install_file "${ours}" "${theirs}" || return 1

  # this is just semantically easier...
  ln -fs ${HOME}/.config/msmtp/config ${HOME}/.msmptrc || return 0

  # We will assume passwords have been set. Unlike mbsyncrc, sending email
  # is completely optional.
  info "msmtp files have been installed"
  return 0
}

validate_requirements() {
  func=${FUNCNAME[0]}

  requires=(neomutt mbsync msmtp notmuch abook)
  valid=true
  for i in ${requires[*]}; do
    if ! which $i >& /dev/null; then
      err "$func: ${i} not installed"
      valid=false
    fi
  done

  if [[ ! -e "/etc/ssl/ca-bundle.pem" ]]; then
    err "unable to find ca-bundle.pem in /etc/ssl"
    valid=false
  elif [[ ! -e "/etc/ssl/certs/SUSE_Trust_Root.pem" ]]; then
    err "unable to find SUSE trust root; please install certificates"
    valid=false
  fi

  if $valid; then return 0 ; else return 1 ; fi
}


setup_binaries() {
  info "installing mutt scripts"

  neomutt_bin="$(which neomutt)"
  [[ -z "${neomutt_bin}" ]] && \
    err "unable to find neomutt binary in PATH" && return 1
  install_bin_script "${neomutt_bin}" "mutt" || return 1

  for script in mailsync muttimage openfile; do
    scriptloc="${cwd}/mutt/mw-install/bin/${script}"
    install_bin_script "${scriptloc}" "${script}"
  done
  return 0
}

setup_mutt() {
  func="${FUNCNAME[0]}"
  info "$func: setting up mutt"

  if ! validate_requirements ; then
    err "missing requiremens."
    return 1
  fi

  install_mutt || return 1
  install_mbsync || return 1
  install_msmtp || return 1

  ln -fs ${HOME}/.config/mutt/notmuch-config ${HOME}/.notmuch-config

  setup_binaries || return 1

  return 0
}

do_setup() {
  setup_mutt || return 1
  info "mutt has been configured"
  return 0
}


do_setup || exit 1
