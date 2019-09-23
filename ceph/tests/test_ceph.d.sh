#!/bin/bash
#
# Test ceph.d.sh 
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

set -x
set -e

cwd=$(pwd)

source ${cwd}/ceph/ceph.d/ceph.d.sh || exit 1

tmpdir=$(mktemp -d)
test_release_dir="${tmpdir}"

release_file=$(get_release_file ${test_release_dir})
[[ "${release_file}" == "${tmpdir}/src/ceph_release" ]] || exit 1

mkdir -p ${tmpdir}/src
echo -e "123\nfoobar\n123" > ${tmpdir}/src/ceph_release

release_name=$(get_release_name ${tmpdir})
[[ "${release_name}" == "foobar" ]] || exit 1

echo "OK"

rm -fr ${tmpdir}
