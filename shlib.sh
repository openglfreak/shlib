shlib_root="$(pwd)"
shlib_include="$shlib_root/include"

#params: <library> <function> <error> [additional]
error() {
    local errmsg=
    case $3 in
        #params
        PARAM_NOFILE)
            errmsg='No file specified'
            errno=1
            ;;
        #files
        FILE_NOT_FOUND)
            errmsg="$4: No such file or directory"
            errno=16
            ;;
        FILE_IS_DIRECTORY)
            errmsg="$4: Is a directory"
            errno=17
            ;;
        FILE_NOT_READABLE)
            errmsg="$4: Permission denied"
            errno=18
            ;;
        FILE_NOT_WRITABLE)
            errmsg="$4: Permission denied"
            errno=19
            ;;
        #shlib
        SHLIB_INCLUDE_INVALID_PATH)
            errmsg="$4: Permission denied: File not in include path"
            errno=128
            ;;
        #custom
        CUSTOM)
            errmsg="$(shift 3; printf '%s ' "$*")" #" <-- gedit workaround
            ;;
        #unknown
        *)
            errmsg="$4"
            ;;
    esac
    printf '%b%s.%s: %s%b\n' '\e[31m' "$1" "$2" "$errmsg" '\e[0m' >&2
    return 1
}

#params: <file.sh>
is_included() {
    printf '%s' "$included" |\
        while read file; do
            [ "$file" = "$1" ] && break
        done && return 0
    return 1
}

#params: <file.sh/library>
resolve_include() {
    local file="$1"
    if [ -n "${file##*.sh}" ] && [ -n "${file##*/*}" ]; then
        local library="${file%%.*}"
        file="${file#*.}"
        while [ -z "${file##*.*}" ]; do
            file="${file%%.*}/${file#*.}"
        done
        file="$shlib_include/$library/$file.sh"
        if [ ! -f "$file" ] && [ -d "${file%.sh}" ]; then
            file="${file%.sh}/${file##*/}"
        fi
    elif [ -z "${file##/*}" ]; then
        file="$shlib_include$file"
    else
        file="$(pwd)/$file"
    fi
    printf '%s' "$file"
}

#params: <file.sh>
include_file() {
    local file="$1"
    [ -n "$file" ] || error shlib include PARAM_NOFILE || return
    [ -e "$file" ] || error shlib include FILE_NOT_FOUND "$file" || return
    [ ! -d "$file" ] || error shlib include FILE_IS_DIRECTORY "$file" || return
    [ -r "$file" ] || error shlib include FILE_NOT_READABLE "$file" || return
    . "$file"
}

#params: <file.sh/library>
include() {
    local file="$(resolve_include "$1")"
    is_included "$file" && return
    local dir="$(cd "${file%/*}" 2>/dev/null && pwd)"
    [ -z "${dir##$shlib_include/*}" ] || error shlib include SHLIB_INCLUDE_INVALID_PATH "$file" || return
    include_file "$file" || return
    included="$included
$file"
}

#params: <file.sh/library>
reinclude() {
    local file="$(resolve_include "$1")"
    local dir="$(cd "${file%/*}" 2>/dev/null && pwd)"
    [ -z "${dir##$shlib_include/*}" ] || error shlib include SHLIB_INCLUDE_INVALID_PATH "$file" || return
    include_file "$file" || return
    included="$included
$file"
}
