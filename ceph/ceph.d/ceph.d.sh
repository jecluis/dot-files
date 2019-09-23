#!/bin/bash
#
# Helpers for ceph.d
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


# PLACEHOLDERS info:
#
# %release_root_dir% - the location for the repo's root directory

# specifies the location of the release file, relative to a provided
# ceph root directory.
#
ceph_release_file="%release_root_dir%/src/ceph_release"

get_release_file() {
  root_dir="${1}"
  tmp_str="$(echo ${ceph_release_file} | \
    sed 's/%release_root_dir%/$root_dir/')"

  release_file=$(eval echo "$tmp_str")
  echo "${release_file}"
  return 0
}

get_release_name() {

  root_dir="${1}"
  release_file=$(get_release_file ${root_dir})

  cat ${release_file} | head -n 2 | tail -n 1
  return 0
}

