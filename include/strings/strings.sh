#params: [string] [pos]
charat() {
   printf '%s' "$1" | head -c $(($2+1)) | tail -c 1
}

#params: [string] [start] [length]
substring() {
    local string="$1"
    [ -n "$2" ] && string="$(printf '%s' "$string" | tail -c +$(($2+1)))"
    [ -n "$3" ] && string="$(printf '%s' "$string" | head -c $(($3)))"
    printf '%s' "$string"
}

#params [string] [text]
contains() {
    printf '%s' "$1" | grep -q -F "$2"
}

#params [string] [text]
indexof() {
    [ -n "$2" ] && printf '%s' "$1" | grep -o -m 1 -b -F "$2" | grep -o '^[0-9]*' || printf '%s\n' '-1'
}

#params [string] [text] [splitchar]
indexof_split() {
    [ -n "$2" ] && split_nl "$1" "${3:- }" | grep -m 1 -n -F "$2" | grep -o '^[0-9]*' || printf '%s\n' '-1'
}

#params: [string] [char]
split() {
    printf '%s' "$1" | tr "${2:-,}" ' '
}

#params: [string] [pat]
split_regex() {
    printf '%s' "$1" | sed "s/${2:-,}/ /g"
}

#params: [string] [char]
split_nl() {
    printf '%s' "$1" | tr "${2:- }" '\n'
}

#params: [string] [pat]
split_regex_nl() {
    printf '%s' "$1" | sed "s/${2:- }/\\n/g"
}

#params [times] [char]
repeat() {
    printf '%*s' "$1" | tr ' ' "${2:- }"
}

#params [times] [string]
repeat_string() {
    [ -z "$2" ] && printf '%*s' "$1" || printf '%*s' "$1" | sed "s/ /$(escape_replacement $2)/g"
}

#params: [string] [nchars]
splitchars() {
    printf '%s' "$1" | sed "s/$(repeat "${2:-1}" .)/& /g"
}

#params: [string] [nchars]
splitchars_nl() {
    printf '%s' "$1" | sed "s/$(repeat "${2:-1}" .)/&\\n/g"
}

#params: [string]
escape_pattern() {
    printf '%s' "$1" | sed 's/[]\/$*.^[]/\\&/g'
}

#params: [string]
escape_replacement() {
    printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}
