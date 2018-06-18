setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
syntax match tab /\t/
hi CustomPythonTab ctermbg=blue guibg=Blue
hi link tab CustomPythonTab
syntax match eolspc /[ \t]\+$/
"hi eolspc ctermbg=red
hi link eolspc Error
