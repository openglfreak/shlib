include math

#resolvfunc should output the original on failure, and output valid rpn on success
#params: [rpn] [resolvfunc]
resolve_rpn() {
    local tok= tok2=
    expr_referencing=
    expr_resolved=
    expr_unresolved_refs=
    while read tok; do
        if ! is_operator "$tok" && ! is_number "$tok"; then
            expr_referencing="$expr_referencing $tok"
            if [ -n "$2" ]; then
                tok2="$($2 "$tok")"
                ( [ -z "$tok2" ] || [ "$tok2" = "$tok" ] ) && expr_unresolved_refs="$expr_unresolved_refs $tok" || tok="$tok2"
            else
                expr_unresolved_refs="$expr_unresolved_refs $tok"
            fi
        fi
        expr_resolved="$expr_resolved $tok"
    done << EOF
$(printf '%s' "$1" | tr ' ' '\n')
EOF
    expr_referencing="${expr_referencing# }"
    expr_resolved="${expr_resolved# }"
    expr_unresolved_refs="${expr_unresolved_refs# }"
}

#see resolve_rpn
#params: [infix] [resolvfunc]
resolve() {
    resolve_rpn "$(printf '%s' "$1" | inf2rpn)" "$2"
}
