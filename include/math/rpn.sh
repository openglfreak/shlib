include strings
include math

#params: <operator>
_opinf() {
    local index="$(indexof_split "$operators" "$1")"
    [ $index -eq -1 ] && assoc= && precedence= && return 1
    set -- $associativity
    eval assoc=\${$index}
    set -- $precedences
    eval precedence=\${$index}
}

#params: <operator>
_opinf2() {
    local index assoc precedence
    _opinf "$@"
    local ret=$?
    index2=$index
    assoc2=$assoc
    precedence2=$precedence
    return $ret
}

#stdin: [infix]
inf2rpn() {
    split_tokens | (
        while read tok; do
            if _opinf "$tok"; then
                while _opinf2 "$1" &&\
                    ( ( [ $assoc = l ] && [ $precedence -le $precedence2 ] ) ||\
                    ( [ $assoc = r ] && [ $precedence -lt $precedence2 ] ) ); do
                    printf '%s ' "$1"
                    shift
                done
                set -- "$tok" "$@"
                continue
            fi
            case "$tok" in
                \()
                    set -- \( "$@"
                    ;;
                \))
                    while [ "$1" != '(' ]; do
                        printf '%s ' "$1"
                        shift
                    done
                    shift
                    ;;
                *)
                    printf '%s ' "$tok"
                    ;;
            esac
        done
        printf '%s ' "$@"
        echo
    )
}

#stdin: [rpn]
rpn2inf_good() {
    tr ' ' '\n' | (
        local opstack= tok= halt=false
        set --
        while read tok; do
            if _opinf "$tok"; then
                local po=$precedence
                local ao=$assoc
                local v2="$1" v1="$2"
                shift; shift
                local o2="${opstack##* }"
                opstack="${opstack% *}"
                [ "$o2" != . ] && _opinf "$o2" && [ $assoc = l ] && [ $precedence -le $po ] && v2="($v2)"
                local o1="${opstack##* }"
                opstack="${opstack% *}"
                [ "$o1" != . ] && _opinf "$o1" && [ $assoc = l ] && [ $precedence -le $po ] && v1="($v1)"
                set -- "$v1$tok$v2" "$@"
                opstack="$opstack $tok"
            elif [ -n "$(printf '%s' $tok)" ]; then
                set -- "$tok" "$@"
                opstack="$opstack ."
            fi
        done
        printf '%s ' "$@"
        echo
        [ $# -eq 1 ]
    )
}
