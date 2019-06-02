#! /bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

upshell_init() {
   : "${UPSHELL_ERROR_FD:=2}"
   : "${UPSHELL_CACHE_HOME:=${XDG_CACHE_HOME:-${HOME}/.cache}/upshell}"
   : "${UPSHELL_CONFIG_HOME:=${XDG_CONFIG_HOME:-${HOME}/.config}/upshell}"
}

upshell_err() {
   echo "$@" >&"$UPSHELL_ERROR_FD"
}

upshell_fail() {
   upshell_err "$@"
   upshell_err "Failure."
   return 1
}

upshell_assert() {
   test "$@" || upshell_fail "Assertion failed:" "$@"
}

upshell_ord() {
   LC_CTYPE=C printf %d "'$1"
}

upshell_ascii2hex() {
   LC_CTYPE=C printf %x "'$1"
}

upshell_chr() {
   [ "$1" -lt 256 ] || return 1
   printf "\\$(printf '%03o' "$1")"
}

upshell_hex2dec() {
   awk '
      function hex2dec(hex_chars) {
         hex_alphabet = "0123456789abcdef"
         len = length(hex_chars)
         for (i = 1; i <= len; i++) {
            x = index(hex_alphabet, substr(hex_chars, i, 1))
            if (!x) {
              return "NaN"
            }
            ord = (16 * ord) + x - 1
         }
         return ord
      }
      BEGIN {
         print hex2dec(tolower(ARGV[1]))
      }' "$1"
}

upshell_hex2ascii() {
   # The following does not work with 'dash':
   # printf "\\x$1"

   # The following does not work on Busybox's 'xxd':
   # echo "$1" | xxd -r -p

   upshell_chr "$(upshell_hex2dec "$1")"
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
   od -An -t xC | tr -d ' \n'
   #  upshell_split_string |
   #     while IFS= read -r char; do
   #        upshell_ascii2hex "$char"
   #     done
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
         upshell_zsh_setopt -o nullglob
         upshell_bash_shopt -s nullglob
         for dir in *; do
            [ -d "$dir" ] || continue
            echo "$(upshell_hex2url "$dir")"
         done
      )
   fi
}

upshell_shell_type() (

   # For `type declare`:
   # - Bash echoes "declare is a shell builtin".
   # - zsh echoes "declare is a reserved word".
   # - dash echoes "declare: not found".
   # - ksh echoes "ksh: whence: declare: not found" to stderr.
   # - Busybox shell echoes "declare: not found".

   last1=''
   last2=''
   for word in $(type declare 2> /dev/null); do
      last1="$last2"
      last2="$word"
   done

   # For `type -p`:
   # - ksh yields a return code of 2
   # - dash yields a return code of 127
   # - Busybox shell yields a return code of 0

   if type -p > /dev/null 2>&1; then
      retval="$?"
   else
      retval="$?"
   fi

   case "$last1"_"$last2"_"$retval" in
      shell_builtin_*) echo 'bash' ;;
      reserved_word_*) echo 'zsh' ;;
      not_found_127) echo 'dash' ;;
      not_found_0) echo 'sh' ;;
      __2) echo 'ksh' ;;
      *) echo 'unknown' ;;
   esac
)

upshell_bash_shopt() {
   case "$(upshell_shell_type)" in
      bash) shopt "$@" ;;
      *) ;;
   esac
}

upshell_zsh_setopt() {
   case "$(upshell_shell_type)" in
      zsh) setopt "$@" ;;
      *) ;;
   esac
}

upshell_delete_cache() {
   if [ "$UPSHELL_CACHE_HOME" ] &&
      [ -d "$UPSHELL_CACHE_HOME" ]; then
      (
         CDPATH= cd -- "$UPSHELL_CACHE_HOME"
         upshell_zsh_setopt -o nullglob
         upshell_bash_shopt -s nullglob
         for dir in *; do
            [ -d "$dir" ] || continue
            echo Removing "$(upshell_hex2url "$dir")"
            rm -fr "$dir"
         done
      )
   fi
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

upshell_load_helper() (
   # Context: we are in a directory in which something must be sourced.
   for f in *.sh; do
      [ -f "$f" ] || continue
      . "$f"
   done
   if [ -d "./bin" ]; then
      PATH="$PWD/bin:$PATH"
   fi
)

upshell_load() (
   set -eu

   upshell_clone "$1" || upshell_fail "Failed to load $1"

   repo_dir="$UPSHELL_CACHE_HOME"/"$(upshell_url2hex "$1")"
   CDPATH= cd -- "$repo_dir"
   if [ "$2" ]; then
      if [ -f "$2" ]; then
         . "$2"
      elif [ -d "$2" ]; then
         CDPATH= cd -- "$2"
         upshell_load_helper
      else
         upshell_fail "No file or directory named $2 in $1."
      fi
   else
      upshell_load_helper
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
