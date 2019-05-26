#! /bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

#upshell_split_pairs() {
#  awk '{ gsub("..", "&\n") ; printf("%s",$0) }'
#}
#
#upshell_hex2string() {
#  upshell_split_pairs |
#     while read pair; do
#        upshell_hex2ascii "$pair"
#     done
#}
#
#upshell() {
#   :
#}
