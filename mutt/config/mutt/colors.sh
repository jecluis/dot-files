#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <foreground> [<background>]"
  exit 1
fi

c_fg=${1}
c_bg=${2}
[[ -z "${c_bg}" ]] && c_bg=0

color_fg="38;5;${c_fg}"
color_bg="48;5;${c_bg}"

color="\e[${color_bg};${color_fg}m"

reset='\e[0m'
bold='\e[1m'

echo -e "${reset}${color}     foo bar baz - ${bold}FOO BAR BAZ      ${reset}"\
        "   (bg: ${c_bg}\t\tfg: ${c_fg})"
