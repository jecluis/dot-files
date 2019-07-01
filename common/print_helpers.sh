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

# read: \e[A;Bm with
#  A = modifier
#   0 - reset all attributes
#   1 - bold
#  Should we specify \e[0;Bm then we are essentially saying the color B will
#  not be subject to any previous modifier. With \e[1;B, we're stating that
#  B will be modified with bold.
#
# B = color
#   0 - reset all attributes
#   1 - set bold
#   91 - Light red
#   93 - Light yellow
#   96 - Light Cyan
#
# More info:
#   http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
#   https://misc.flogisoft.com/bash/tip_colors_and_formatting (with a table)
#
color_reset='\e[0m'
color_info='\e[1;96m'
color_err='\e[1;91m'
color_bold='\e[0;1m'
color_warn='\e[1;93m'

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

warn() {
  echo -e "${color_warn}warning: ${color_bold}$*${color_reset}"
}
