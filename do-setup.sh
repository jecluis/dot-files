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
source common/install_helpers.sh

cd $(dirname $0)
cwd=$(pwd)

available=($(find . -iname 'do_setup.sh' | xargs dirname | xargs))

available=()
for thing in $(find . -iname 'do_setup.sh'); do
  name=$(basename $(realpath $(dirname ${thing})))
  [[ -z "${name}" ]] && \
    err "ended up with empty dir name for '${thing}'" && \
    continue

  available=(${available[*]} $name)
done

is_available() {
  what="${1}"
  [[ -z "${what}" ]] && \
    err "${FUNCNAME[0]}: expected argument" && exit 1

  for i in ${available[*]}; do
    [[ "${i}" == "${what}" ]] && return 0
  done
  return 1
}

to_run=()
while [[ $# -gt 0 ]]; do

  case $1 in
    -h|--help|help)
      avail="$(echo ${available[*]} | sed 's/ / \| /g')"
      echo "usage: $0 [${avail}]"
      exit 0
      ;;
    *)
      if ! is_available "$1" ; then
        err "we don't recognize '${1}'"
        exit 1
      fi

      to_run=(${to_run[*]} ${1})
      ;;
  esac
  shift
done

if [[ ${#to_run[*]} -eq 0 ]]; then
  to_run=(${available[*]})
fi

# ensure all scripts exist and are executable
for thing in ${to_run[*]}; do

  script="$(realpath -m ./${thing}/do_setup.sh)"
  [[ ! -e "${script}" ]] && \
    err "unable to find setup script for '${thing}' at '${script}'" && \
    exit 1
  [[ ! -x "${script}" ]] && \
    err "setup script at '${script}' for '${thing}' is not executable" && \
    exit 1
done

for thing in ${to_run[*]}; do

  script="$(realpath -m ./${thing}/do_setup.sh)"
  info "running install script for '${thing}'"
  ${script} || exit 1

done

