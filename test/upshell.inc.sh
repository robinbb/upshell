#! /bin/sh

set -eu
set -x

dir="$(dirname "$0")"
shfmt -p -i 3 -ci -sr -d "$dir"/../upshell.inc.sh
shfmt -p -i 3 -ci -sr -d "$0"

. "$dir"/../upshell.inc.sh

[ "$(upshell_ord A)" = '65' ]
[ "$(upshell_ord a)" = '97' ]
[ "$(upshell_ord @)" = '64' ]

[ "$(upshell_chr 65)" = 'A' ]
[ "$(upshell_chr 97)" = 'a' ]
[ "$(upshell_chr 64)" = '@' ]

[ "$(upshell_ascii2hex A)" = '41' ]
[ "$(upshell_ascii2hex 0)" = '30' ]
[ "$(upshell_ascii2hex Z)" = '5a' ]
[ "$(upshell_ascii2hex a)" = '30' ]
[ "$(upshell_ascii2hex z)" = '30' ]
[ "$(upshell_ascii2hex @)" = '30' ]
[ "$(upshell_ascii2hex /)" = '30' ]

# printf %s "416142624363" |
#   upshell_
