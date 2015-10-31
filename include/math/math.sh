include strings

operators='| ^ & << >> + - * / % ** ~'
associativity='l l l l l l l l l l r r'
precedences='0 1 2 3 3 4 4 5 5 5 6 7'

decimal_regexf='\([1-9][0-9]*\(\.[0-9]\)\?\|0\)'
decimal_regexi='[1-9][0-9]*'
octal_regex='0[0-7]*'
hexadecimal_regex='0x[0-9A-Fa-f]*'

variable_regex='[A-Za-z_][A-Za-z0-9_]*'
operator_chars="-$(escape_pattern "$operators" | tr -d ' ' | tr -d '-')"
operator_regex="\($(escape_pattern "$operators" | sed 's/ /\\)\\|\\(/g')\)"

#stdin: <infix>
split_tokens() {
    grep -o -e '[()]' -e "$decimal_regexf" -e "$octal_regex" -e "$hexadecimal_regex" -e "$variable_regex" -e "$operator_regex" -e '[^[:space:]]'
}

#params: <string>
is_operator() {
    printf '%s' "$operators " | grep -q -F "$1 "
}

#params: <string>
is_number() {
    printf '%s' "$1" | grep -q -e "^[+-]\?$decimal_regexf$" -e "^[+-]\?$octal_regex$" -e "^[+-]\?$hexadecimal_regex$"
}

#params: <string>
is_integer() {
    [ -n "${1##*.*}" ] && is_number "$1"
}

#params: <string>
is_immediate_expr() {
    printf '%s' "$1" | _readtoks | grep -q -v -e "$variable_regex"
}

#params: <rpn...>
rpn2inf() {
    printf '%s' "$*" | sed ":b s/\([^ ][^ ]*\)  *\([^ ][^ ]*\)  *\($operator_regex\)/(\1\3\2)/; tb"
}

#params: <rpn...>
calculate_rpn() {
    [ $# -eq 0 ] || (rpn2inf "$@"; echo) | bc
}

#params: <infix...>
calculate() {
    [ $# -eq 0 ] || printf '%s\n' "$*" | bc
}
