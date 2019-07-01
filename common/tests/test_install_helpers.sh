#!/bin/bash
#
# Test common/install_helpers.sh
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

source ../print_helpers.sh
source ../install_helpers.sh

set -xe

files_match() {
  sha_a=$(sha256sum ${1} | cut -f1 -d' ')
  sha_b=$(sha256sum ${2} | cut -f1 -d' ')

  [[ "$sha_a" == "$sha_b" ]] && return 0
  return 1
}

info "start test $0"

dir=$(mktemp -d dot-files-test_install_helpers.XXX)

bindir=$(realpath $dir/bin)
confdir=$(realpath $dir/conf)
srcdir=$(realpath $dir/src)

mkdir $bindir $confdir $srcdir || exit 1

files=(aa bb cc)
for i in ${files[*]}; do
  echo "$i" >> $srcdir/$i
done

install_file $srcdir/aa $confdir/aa.conf
[[ -e "${confdir}/aa.conf" ]] || exit 1
[[ -L "${confdir}/aa.conf" ]] || exit 1
echo ">>> $srcdir"
files_match "${confdir}/aa.conf" "$srcdir/aa" || exit 1
check_file_installed ${confdir}/aa.conf || exit 1

backup_file "${confdir}/aa.conf" || exit 1
[[ ! -e "${confdir}/aa.conf" ]] || exit 1
[[ -e "${confdir}/aa.conf.bak" ]] || exit 1
touch ${confdir}/aa.conf || exit 1
backup_file "${confdir}/aa.conf" || exit 1
[[ ! -e "${confdir}/aa.conf" ]] || exit 1
[[ -e "${confdir}/aa.conf.bak.~1~" ]] || exit 1

old_HOME="${HOME}"
HOME=${dir}

install_script $srcdir/bb bb || exit 1
[[ -e "${bindir}/bb" ]] || exit 1

check_file_installed ${bindir}/bb || exit 1
check_installed_script_exists "bb" || exit 1
files_match "${srcdir}/bb" "${bindir}/bb" || exit 1
backup_bin_script "bb" || exit 1
[[ ! -e "${bindir}/bb" ]] || exit 1
check_installed_script_exists "bb" && exit 1
check_file_installed ${bindir}/bb && exit 1

check_installed_script_exists "bb.bak" || exit 1
check_file_installed "${bindir}/bb.bak" || exit 1

install_bin_script ${srcdir}/cc cc || exit 1
check_installed_script_exists "cc" || exit 1
files_match "${srcdir}/cc" "${bindir}/cc" || exit 1
check_file_installed "${bindir}/cc" || exit 1

echo "OK"
exit 0
