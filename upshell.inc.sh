#! /bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

upshell_init() {
   : "${UPSHELL_ERROR_FD:=2}"
   : "${UPSHELL_CACHE_HOME:=${XDG_CACHE_HOME:-${HOME}/.cache}/upshell}"
   : "${UPSHELL_CONFIG_HOME:=${XDG_CONFIG_HOME:-${HOME}/.config}/upshell}"
}

upshell_ord() {
   LC_CTYPE=C printf %d "'$1"
}

upshell_chr() {
   [ "$1" -lt 256 ] || return 1
   printf "\\$(printf %o "$1")"
}

upshell_ascii2hex() {
   LC_CTYPE=C printf %x "'$1"
}

upshell_hex2ascii() {
   printf "\\x$1"
}

upshell_split_string() {
   awk '{ gsub(".", "&\n") ; printf("%s", $0) }'
}

upshell_split_pairs() {
   awk '{ gsub("..", "&\n") ; printf("%s", $0) }'
}

upshell_hex2string() {
   upshell_split_pairs |
      while IFS= read -r pair; do
         upshell_hex2ascii "$pair"
      done
}

upshell_string2hex() {
   upshell_split_string |
      while IFS= read -r char; do
         upshell_ascii2hex "$char"
      done
}

upshell_err() {
   echo "$1" >&"$UPSHELL_ERROR_FD"
}

upshell_fail() {
   upshell_err "$1"
   upshell_err "Failure."
   return 1
}

upshell_require() {
   command -v "$1" > /dev/null ||
      upshell_fail "The '$1' executable is required, but is not on the PATH."
}

upshell_url2hex() {
   printf '%s' "$1" | upshell_string2hex
}

upshell_hex2url() {
   printf '%s' "$1" | upshell_hex2string
}

upshell_list() {
   if [ -d "$UPSHELL_CACHE_HOME" ]; then
      (
         CDPATH= cd -- "$UPSHELL_CACHE_HOME"
         for dir in *; do
            [ -d "$dir" ] || continue
            echo "$(upshell_hex2url "$dir")"
         done
      )
   fi
}

upshell_delete_cache() {
   [ "$UPSHELL_CACHE_HOME" ] &&
      [ -d "$UPSHELL_CACHE_HOME" ] &&
      (
         CDPATH= cd -- "$UPSHELL_CACHE_HOME"
         for dir in *; do
            [ -d "$dir" ] || continue
            echo Removing "$(upshell_hex2url "$dir")"
            rm -fr "$dir"
         done
      )
}

upshell_clone() (
   repo_dir="$UPSHELL_CACHE_HOME"/"$(upshell_url2hex "$1")"
   if [ ! -e "$repo_dir" ]; then
      upshell_require git
      git clone \
         --depth 1 \
         --recursive \
         -b master \
         "$1" \
         "$repo_dir" ||
         upshell_fail "git clone failed"
   fi
)

upshell() {
   case "$1" in
      'list')
         shift
         upshell_list "$@"
         ;;
      *)
         upshell_clone "$@"
         ;;
   esac
}

upshell_init
# upshell "$@"
