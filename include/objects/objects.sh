include strings

# format is [typename]:[typename_var]
types=

#stdin: <type>
add_type() {
    local name
    read name
    [ -n "${a##*[^A-Za-z0-9_]*}" ] || error objects add_type CUSTOM "Invalid type name: '$name'" || return
    ! contains " $types " " $name:" || error objects add_type CUSTOM "$name redefined" || return
    local mname mtype
    while read mname mtype; do
        [ -n "${a##*[^A-Za-z0-9_]*}" ] || error objects add_type CUSTOM "$name: Invalid member name: '$mname'" || return
        
    done
}

add_type << EOF
object
test int
EOF
