#! /bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

upshell_init() {
   : "${UPSHELL_ERROR_FD:=2}"
   : "${UPSHELL_CACHE_HOME:=${XDG_CACHE_HOME:-${HOME}/.cache}/upshell}"
   : "${UPSHELL_CONFIG_HOME:=${XDG_CONFIG_HOME:-${HOME}/.config}/upshell}"
   : "${UPSHELL_GENERATED_HOME:=${UPSHELL_CACHE_HOME}/home}"
   : "${UPSHELL_RC:=${UPSHELL_CONFIG_HOME}/upshell.config}"
}

upshell_err() {
   eval "echo \"$1\" >&${UPSHELL_ERROR_FD}"
}

upshell_fail() {
   upshell_err "$1"
   upshell_err "Failure."
   return 1
}

upshell_assert() {
   test "$@" || upshell_fail "Assertion failed: $*"
}

upshell_ord() {
   LC_CTYPE=C printf %d "'$1"
}

upshell_ascii2hex() {
   LC_CTYPE=C printf %x "'$1"
}

upshell_chr() {
   [ "$1" -lt 256 ] || return 1
   # shellcheck disable=SC2059
   printf "\\$(printf '%03o' "$1")"
}

upshell_hex2dec() {
   upshell_require awk
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
   upshell_require awk
   awk '{ gsub(".", "&\n") ; printf("%s", $0) }'
}

upshell_split_pairs() {
   upshell_require awk
   awk '{ gsub("..", "&\n") ; printf("%s", $0) }'
}

upshell_hex2string() {
   upshell_split_pairs |
      while IFS= read -r pair; do
         upshell_hex2ascii "$pair"
      done
}

upshell_string2hex() {
   upshell_require od
   upshell_require tr
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
         CDPATH='' cd -- "$UPSHELL_CACHE_HOME" || return 1
         upshell_zsh_setopt -o nullglob
         upshell_bash_shopt -s nullglob
         for dir in *; do
            [ -d "$dir" ] || continue
            upshell_hex2url "$dir"
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

   # shellcheck disable=SC2039
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
      bash)
         # shellcheck disable=SC2039
         shopt "$@"
         ;;
      *)
         # Do nothing on non-Bash shells.
         ;;
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
         CDPATH='' cd -- "$UPSHELL_CACHE_HOME" || return 1
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
   repo_url="$1"
   ref='master'
   if [ "$#" -gt 1 ]; then
      if [ "$2" ]; then
         ref="$2"
      fi
   fi
   upshell_url="$repo_url"@"$ref"
   repo_dir="$UPSHELL_CACHE_HOME"/"$(upshell_url2hex "$upshell_url")"
   if [ ! -e "$repo_dir" ]; then
      upshell_require git
      git clone -q --depth 1 -b "$ref" "$repo_url" "$repo_dir"
   fi
   echo "$repo_dir"
)

upshell_phases='
   pre-login.bash
   pre-login.sh
   login.bash
   login.sh
   post-login.sh
   post-login.bash
   interactive.sh
   interactive.bash
'

upshell_ensure_dir() {
   mkdir -p "$1"
}

upshell_ensure_file() {
   if [ ! -e "$1" ]; then
      upshell_ensure_dir "$(dirname "$1")"
      touch "$1"
   fi
}

upshell_generate_phases() (

   # This is to get splitting on whitespace in the `for p in ps` construct.
   #
   upshell_zsh_setopt shwordsplit

   if [ -e "$UPSHELL_RC" ]; then
      upshell_ensure_dir "$UPSHELL_GENERATED_HOME"
      for phase in $upshell_phases; do
         rm -f "$UPSHELL_GENERATED_HOME"/"$phase"
      done
      while read -r cmd; do
         upshell_require cut
         subcommand="$(echo "$cmd" | cut -f1 -d ' ')"
         case "$subcommand" in
            'upshell-module')
               module="$(echo "$cmd" | cut -f2 -d ' ')"
               if [ ! "$module" ]; then
                  upshell_fail "No module specified on 'upshell-module'."
               fi
               repo="$(echo "$cmd" | cut -f3 -d ' ')"
               if [ ! "$repo" ]; then
                  repo="$(upshell_home_repo)"
               fi

               ref="$(echo "$cmd" | cut -f4 -d ' ')"
               repo_dir="$(upshell_clone "$repo" "$ref")"
               dir="$repo_dir"/modules/"$module"
               if [ -e "$dir" ]; then
                  upshell_require cat
                  for phase in $upshell_phases; do
                     if [ -e "$dir"/"$phase" ]; then
                        {
                           echo
                           echo "# ${repo}/modules/${module}:"
                           echo
                           cat "$dir"/"$phase"
                        } >> "$UPSHELL_GENERATED_HOME"/"$phase"
                     fi
                  done
               fi
               ;;
            *)
               upshell_fail "Unhandled subcommand: $subcommand"
               ;;
         esac
      done < "$UPSHELL_RC"
   fi
)

upshell_home_repo() {
   echo 'https://github.com/robinbb/upshell'
}

upshell_add_upshell_module() (
   module="$1"
   repo="$(upshell_home_repo)"
   ref='master'
   if [ "$#" -gt 1 ]; then
      repo="$2"
      if [ "$#" -gt 2 ]; then
         ref="$3"
      fi
   fi
   repo_dir="$(upshell_clone "$(upshell_home_repo)" "$ref")"
   if [ -d "$repo_dir"/modules/"$module" ]; then
      upshell_ensure_file "$UPSHELL_RC"
      echo "upshell-module $module $repo $ref" >> "$UPSHELL_RC"
      upshell_generate_phases
      upshell_generate_rc_files
   else
      upshell_fail "The module '$module' does not exist."
   fi
)

upshell_generate_dot_profile() {
   rc="$UPSHELL_GENERATED_HOME"/.profile
   echo '# This file was generated by Upshell. Do not modify!' > "$rc"

   src="$UPSHELL_GENERATED_HOME"/pre-login.sh
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/login.sh
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   if [ "$(echo "$UPSHELL_GENERATED_HOME"/*interactive*)" ]; then
      {
         echo
         # shellcheck disable=SC2016
         echo 'if [ "$PS1" ]; then'
      } >> "$rc"

      src="$UPSHELL_GENERATED_HOME"/pre-interactive.sh
      if [ -e "$src" ]; then
         {
            echo
            cat "$src"
         } >> "$rc"
      fi

      src="$UPSHELL_GENERATED_HOME"/interactive.sh
      if [ -e "$src" ]; then
         {
            echo
            cat "$src"
         } >> "$rc"
      fi

      src="$UPSHELL_GENERATED_HOME"/post-interactive.sh
      if [ -e "$src" ]; then
         {
            echo
            cat "$src"
         } >> "$rc"
      fi

      {
         echo
         echo 'fi'
      } >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/post-login.sh
   if [ -e "$src" ]; then
      {
         echo
         cat "$src"
      } >> "$rc"
   fi
   unset rc src
}

upshell_generate_dot_bashrc() {
   rc="$UPSHELL_GENERATED_HOME"/.bashrc
   echo '# This file was generated by Upshell. Do not modify!' > "$rc"

   src="$UPSHELL_GENERATED_HOME"/pre-interactive.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/pre-interactive.sh
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/interactive.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/interactive.sh
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   {
      echo
      # shellcheck disable=SC2016
      echo 'if [ -z "$UPSHELL_NO_ETC_BASHRC" ] && [ -r /etc/bashrc ]'
      echo 'then'
      echo '   . /etc/bashrc'
      echo 'fi'
   } >> "$rc"

   src="$UPSHELL_GENERATED_HOME"/post-interactive.sh
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/post-interactive.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   unset rc src
}

upshell_generate_dot_bash_profile() {
   rc="$UPSHELL_GENERATED_HOME"/.bash_profile
   echo '# This file was generated by Upshell. Do not modify!' > "$rc"

   src="$UPSHELL_GENERATED_HOME"/pre-login.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   src="$UPSHELL_GENERATED_HOME"/login.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   echo >> "$rc"
   echo '[ -r ~/.profile ] && . ~/.profile' >> "$rc"

   src="$UPSHELL_GENERATED_HOME"/post-login.bash
   if [ -e "$src" ]; then
      echo >> "$rc"
      cat "$src" >> "$rc"
   fi

   unset rc src
}

upshell_generate_rc_files() {
   upshell_generate_dot_profile
   upshell_generate_dot_bash_profile
   upshell_generate_dot_bashrc
}

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
