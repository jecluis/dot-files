#!/bin/bash
#
# Setup password store 
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

is_debug=false
debug() {
  caller="${FUNCNAME[1]}"
  func="${caller}/debug"
  if $is_debug ; then
    bolden "$func: ${color_reset}$*"
  fi
}

cwd=$(pwd)
storedir="${HOME}/.password-store"
ourdir="$(dirname $0)"

keyid=
auto_keyid=

store_exists() {
  [[ -d "${storedir}" ]] && return 0
  return 1
}

store_is_git() {

  if ! store_exists ; then return 1 ; fi

  if [[ ! -d "${storedir}/.git" ]]; then return 1 ; fi
  return 0
}

gpg_valid_key() {

  keyid="${1}"
  [[ -z "${keyid}" ]] && \
    err "${FUNCNAME[0]}: must provide a key as argument; die." && \
    exit 1

  if ! gpg --list-secret-keys ${keyid} >& /dev/null ; then
    return 1
  fi

  return 0
}

gpg_auto_get_keyid () {
  func="${FUNCNAME[0]}"
  debug "gpg home: $GNUPGHOME ; $PASSWORD_STORE_GPG_DIR"

  varname=\$"$1"
  [[ -z "$varname" ]] && \
    err "$func: requires two arguments for keyid and uid name" && \
    exit 1 # die
  varname=\$"$2"
  [[ -z "$varname" ]] && \
    err "$func: requires two arguments for keyid and uid name" && \
    exit 1 # die

  keyid=

  debug "get keys_arr"
  IFS=$'\n'
  keys_arr=($(gpg --list-secret-keys --with-colon | grep '^sec'))
  debug "keys_arr = ${keys_arr[*]}"

  if [[ ${#keys_arr[*]} -eq 0 ]]; then
    err "$func: unable to find an available gpg key"
    return 1
  fi

  debug "get keyid"
  keyid=""
  for ((i=0; i < ${#keys_arr[*]}; i++)); do
    key_str="${keys_arr[$i]}"
    if [[ -z "${key_str}" ]]; then
      warn "$func: empty secret key entry from gpg keyring (?)"
      continue
    fi

    IFS=':' read -r -a key_fields <<< "${key_str}"
    if [[ ${#key_fields[*]} -eq 0 ]]; then
      warn "$func: secret key contains no fields (?)"
      continue
    fi
    keyid="${key_fields[4]}"
    if [[ -z "${keyid}" ]]; then
      warn "$func: unable to obtain secret key id; attempt next"
      continue
    fi
    break
  done
  if [[ -z "${keyid}" ]]; then
    err "$func: unable to find a candidate key"
    return 1
  fi

  debug "keyid: ${keyid}"
  debug "get uid_name; gpg home: $GNUPGHOME; $PASSWORD_STORE_GPG_DIR"
  IFS=$'\n'
  uid_name=
  uids=($(gpg --list-secret-keys --with-colon ${keyid} | grep '^uid'))
  debug "uids: ${uids[*]}"
  for ((i=0; i < ${#uids[*]}; i++)); do
    uid_str=${uids[$i]}
    [[ -z "${uid_str}" ]] && continue

    IFS=':' read -r -a uid_fields <<< ${uid_str}
    [[ ${#uid_fields[*]} -eq 0 ]] && continue

    uid_name=${uid_fields[9]}
    break
  done

  if [[ -z "${uid_name}" ]]; then
    err "$func: unable to obtain name for key '${keyid}'"
    return 1
  fi

  eval "$1=\"$keyid\""
  eval "$2=\"$uid_name\""
  return 0
}

store_create() {
  func="${FUNCNAME[0]}"

  keyid=${keyid:-""}

  info "creating store..."
  if [[ $auto_keyid == 1 ]]; then
    keyname=
    if ! gpg_auto_get_keyid keyid keyname ; then
      err "$func: error automatically obtaining keyid for store creation"
      return 1
    elif [[ -z "${keyid}" ]]; then
      err "unable to automatically find a keyid to create the store"
      return 1
    fi
    info "using keyid [ $keyid   $keyname ] for store creation"

  elif [[ -z "$keyid" ]]; then
    while 1; do
      read -r -p "provide key id to use for the store ('l' for list):" keyid
      [[ -z "${keyid}" ]] && continue;
      if [[ "${keyid}" == "l" ]]; then gpg_list_secrets ; continue ; fi
      if ! gpg_valid_key ${keyid}; then
        warn "invalid key id '${keyid}', try again."
        continue
      fi
      break
    done
  elif ! gpg_valid_key ${keyid}; then
    err "$func: provided key '${keyid}' not valid"
    return 1
  fi

  [[ -z "${keyid}" ]] && \
    err "${func}:${LINENO} > expected to have 'keyid'" && return 1

  pass init ${keyid} || return 1

  return 0
}

load_conf() {

  if [[ ! -e "${ourdir}/pass.conf" ]]; then
    err "unable to find '${ourdir}/pass.conf'"
    return 1
  fi
  source "${ourdir}/pass.conf"

  if [[ -z "${PASSWORD_STORE_GPG_DIR}" ]]; then
    info "PASSWORD_STORE_GPG_DIR is not set in configuration file."
    info "We will assume the default gnupg directory '${HOME}/.gnupg"
    PASSWORD_STORE_GPG_DIR="${HOME}/.gnupg"
    echo "PASSWORD_STORE_GPG_DIR=\"${HOME}/.gnupg\"" >> ${ourdir}/pass.conf
  fi
  export PASSWORD_STORE_GPG_DIR
  export GNUPGHOME=${PASSWORD_STORE_GPG_DIR}

  return 0
}

setup_store() {

  load_conf || return 1

  if ! store_exists ; then
    store_create || return 1
  fi

  return 0
}

setup_git() {
  func="${FUNCNAME[0]}"
  info "$func: setting up store's git repo"

  # our truth repository:
  truth_repo=${PASSWORD_STORE_TRUTH:-""}
  [[ -z "${truth_repo}" ]] && \
    warn "$func: no truth repo set; not setting up git." && \
    return 1

  if [[ ! -d "${HOME}/.password-store/.git" ]]; then
    if ! pass git init; then
      err "$func: unable to init git repository for the password store"
      return 1
    fi
    info "moving our 'master' to a temporary branch to be deleted. "\
         "we do this so we can checkout the real master afterwards."
    pass git branch -M master to_delete
  fi

  remotes=($(pass git remote | grep 'truth'))
  if [[ ${#remotes} -eq 0 ]]; then
    info "$func: adding truth at '${truth_repo}'"
    pass git remote add truth ${truth_repo} || return 1
  fi

  info "$func: updating truth remote"
  pass git remote update truth || return 1
  info "$func: checking out master repository"
  pass git checkout truth/master -b master || return 1
  info "$func: setting upstream for 'master'"
  pass git branch --set-upstream-to=truth/master master || return 1

  if pass git branch | grep 'to_delete' >& /dev/null ; then
    info "removing old 'master' branch"
    pass git branch -D to_delete || return 1
  fi
  return 0
}

update_git() {
  func="${FUNCNAME[0]}"
  if ! pass git status >&/dev/null; then
    info "$func: store does not have git configured; not updating"
    return 0
  fi
  pass git remote update truth || \
    ( err "$func: unable to update 'truth'" ; return 1 )
  pass git pull || \
    ( err "$func: unable to pull from 'truth'"; return 1 )
  return 0
}

validate_gpg_populated() {
  func="${FUNCNAME[0]}"
  gpgdir=${PASSWORD_STORE_GPG_DIR:-${HOME}/.gnupg}

  available_keys=(
    $(gpg --list-secret-keys --with-colon | grep '^sec'))
  if [[ ${#available_keys} -eq 0 ]]; then
    err "no secret keys found in '${gpgdir}'"
    return 1
  fi
  return 0
}

do_setup() {

  func="password-store/${FUNCNAME[0]}"
  keyid=
  auto_keyid=
  while [[ $# -gt 0 ]]; do

    case $1 in
      -k|--keyid)
        ( [[ -z "${2}" ]] || [[ ${2} =~ --* ]] ) && \
          err "$func: '$1' requires a key id as argument" && return 1
        keyid="${2}"
        info "$func: using gpg key '${keyid}' for store"
        shift 1
        ;;
      -a|--autokey)
        info "$func: automatically attempting to obtain gpg key"
        auto_keyid=1
        ;;
      -d|--debug)
        info "$func: setting debug"
        is_debug=true
        ;;
      *)
        warn "$func: unrecognized option '$1'; ignore."
        ;;
    esac
    shift 1
  done

  load_conf || return 1

  if [[ -n "${keyid}" ]]; then
    if ! gpg_valid_key $keyid ; then
      err "provided gpg key id '${keyid}' is invalid"
      return 1
    fi
  fi

  validate_gpg_populated || return 1
  if ! setup_store; then
    err "unable to setup store"
    return 1
  fi
  if ! setup_git err; then
    err "unable to setup store's git"
    return 1
  fi
  if ! update_git; then
    err "unable to update store's git"
    return 1
  fi

  info "password store at '${storedir}' setup"
  info "setup bin symlinks"

  if ! install_script ${ourdir}/pass pass ; then
    err "unable to install 'pass' script to bin directory"
    return 1
  fi
  info "installed 'pass' to bin directory."

  return 0
}


do_setup $* || exit 1
