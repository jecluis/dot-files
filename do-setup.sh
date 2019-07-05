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

#available=($(find . -iname 'run_setup.sh' | xargs dirname | xargs))

available=()
for thing in $(find . -iname 'run_setup.sh'); do
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

precheck_to_run=()
postcheck_to_run=()
run_help=false
run_dry=false
while [[ $# -gt 0 ]]; do

  case $1 in
    -h|--help|help)
      avail="$(echo ${available[*]} | sed 's/ / \| /g')"
      echo "usage: $0 [${avail}]"
      run_help=true
      ;;
    --dry)
      run_dry=true
      ;;
    *)
      if ! is_available "$1" ; then
        err "we don't recognize '${1}'"
        exit 1
      fi

      precheck_to_run=(${precheck_to_run[*]} ${1})
      ;;
  esac
  shift
done

if [[ ${#precheck_to_run[*]} -eq 0 ]]; then
  precheck_to_run=(${available[*]})
fi

# ensure all scripts exist and are executable
for thing in ${precheck_to_run[*]}; do

  path="$(realpath -m ./${thing})"
  setup_script="${path}/run_setup.sh"
  help_script="${path}/run_help.sh"

  [[ ! -e "${setup_script}" ]] && \
    err "unable to find setup script for '${thing}' at '${setup_script}'" && \
    exit 1

  if [[ ! -x "${setup_script}" ]]; then
    err "setup script for '${thing}' at '${setup_script}' is not executable"
    exit 1
  fi

  if $run_help && [[ -e "${help_script}" && -x "${help_script}" ]]; then
    ${help_script}
    continue
  fi
  postcheck_to_run=(${postcheck_to_run[*]} ${thing})

done

$run_help && exit 0

num_run=0
for thing in ${postcheck_to_run[*]}; do

  script="$(realpath -m ./${thing}/run_setup.sh)"
  info "running install script for '${thing}'"
  if ! $run_dry; then
    ${script} || exit 1
  fi
  num_run=$((num_run+1))
done

echo "ran a total of $num_run scripts, out of ${#available[*]} available"

