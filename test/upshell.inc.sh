#! /bin/sh

set -e
set -x

dir="$(dirname "$0")"

# Check formatting of the file under test.
shfmt -p -i 3 -ci -sr -d "$dir"/../upshell.inc.sh

# Check formatting of this file.
shfmt -p -i 3 -ci -sr -d "$0"

# Include the file under test.
. "$dir"/../upshell.inc.sh

# Unit Tests

# upshell_ord

[ "$(upshell_ord A)" = '65' ]
[ "$(upshell_ord a)" = '97' ]
[ "$(upshell_ord @)" = '64' ]

# upshell_chr

[ "$(upshell_chr 65)" = 'A' ]
[ "$(upshell_chr 97)" = 'a' ]
[ "$(upshell_chr 64)" = '@' ]

# upshell_ascii2hex

[ "$(upshell_ascii2hex A)" = '41' ]
[ "$(upshell_ascii2hex 0)" = '30' ]
[ "$(upshell_ascii2hex Z)" = '5a' ]
[ "$(upshell_ascii2hex a)" = '61' ]
[ "$(upshell_ascii2hex z)" = '7a' ]
[ "$(upshell_ascii2hex @)" = '40' ]
[ "$(upshell_ascii2hex /)" = '2f' ]
[ "$(upshell_ascii2hex '')" = '0' ]

# upshell_hex2ascii

[ "$(upshell_hex2ascii 41)" = 'A' ]
[ "$(upshell_hex2ascii 30)" = '0' ]
[ "$(upshell_hex2ascii 0)" = '' ]
[ "$(upshell_hex2ascii 40)" = '@' ]

# upshell_split_string

[ "$(printf %s "416142624363" | upshell_split_string)" \
   = '4
1
6
1
4
2
6
2
4
3
6
3' ]
[ "$(printf %s "string with spaces!" | upshell_split_string)" \
   = 's
t
r
i
n
g
 
w
i
t
h
 
s
p
a
c
e
s
!' ]

# upshell_split_pairs

[ "$(printf %s "416142624363" | upshell_split_pairs)" \
   = '41
61
42
62
43
63' ]

[ "$(printf %s "416142624363" | upshell_hex2string)" \
   = 'AaBbCc' ]
[ "$(printf %s "416142624363" | upshell_string2hex)" \
   = '343136313432363234333633' ]
[ "$(printf %s 'git@github.com/robinbb' | upshell_string2hex)" \
   = '676974406769746875622e636f6d2f726f62696e6262' ]
[ "$(printf %s '676974406769746875622e636f6d2f726f62696e6262' |
   upshell_hex2string)" = 'git@github.com/robinbb' ]

# Property Tests

# Reversibility of upshell_hex2string / upshell_string2hex

test_strings="
abc
123
a1b2c3
https://github.com
string with spaces!
strange characters:
_
-
=
==
\\
\'
git@github.com/robinbb/upshell.git
"

printf %s "$test_strings" | while IFS= read -r str; do
   hex="$(printf %s "$str" | upshell_string2hex)"
   [ "$str" = "$(printf %s "$hex" | upshell_hex2string)" ]
done

# upshell_require

export UPSHELL_ERROR_FD=3
upshell_require sh
upshell_require awk
upshell_require tr
upshell_require git
upshell_require shfmt
! upshell_require exec-not-found-blah
[ "$(upshell_require exec-not-found-blah 3>&1)" \
   = "The 'exec-not-found-blah' executable is required, but is not on the PATH.
Failure." ]

# upshell_delete_cache, upshell_list, upshell_clone, upshell_url2hex
upshell_delete_cache
[ "$(upshell_list)" = '' ]
upshell_clone https://github.com/robinbb/upshell
hexdir="$(upshell_url2hex https://github.com/robinbb/upshell)"
[ -e "$UPSHELL_CACHE_HOME"/"$hexdir" ]
[ "$(upshell_list)" = 'https://github.com/robinbb/upshell' ]

# Clearly indicate completion.
echo 'Success!'
