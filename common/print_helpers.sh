#!/bin/bash
#
# color helpers for, originally, the author's dot-files.
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

has_color=false

if which tput >&/dev/null; then
  num_colors=$(tput colors)
  [[ -n "${num_colors}" ]] && [[ num_colors -ge 8 ]] && has_color=true
fi

color_reset='\e[0m'
color_info='\e[1;96m'
color_err='\e[1;91m'
color_bold='\e[0;1m'

if ! $has_color ; then
  color_reset=
  color_info=
  color_err=
  color_bold=
fi

info() {
  echo -e "${color_info}info: ${color_bold}$*${color_reset}"
}

err() {
  >&2 echo -e "${color_err}error: ${color_bold}$*${color_reset}"
}

bolden() {
  echo -e "${color_bold}$*${color_reset}"
}
