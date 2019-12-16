#! /bin/sh

set -eu

dir="$(dirname "$0")"
shell_type="$1"

# Check formatting of the file under test.
command -v shfmt > /dev/null &&
   shfmt -p -i 3 -ci -sr -d "$dir"/../upshell.inc.sh

# Check formatting of this file.
command -v shfmt > /dev/null &&
   shfmt -p -i 3 -ci -sr -d "$0"

# Include the file under test.
export UPSHELL_ERROR_FD=3
. "$dir"/../upshell.inc.sh

# Unit Tests

# upshell_err, upshell_fail, upshell_assert

[ "$(upshell_err foo 3>&1)" = foo ]
[ "$(upshell_fail "Foo!" 3>&1)" = "Foo!
Failure." ]
upshell_assert 1
upshell_assert X
upshell_assert 1 = 1
upshell_assert X = X
upshell_assert true
upshell_assert "$UPSHELL_CACHE_HOME"
upshell_assert -d .
upshell_assert ! -f .
! upshell_assert 3> /dev/null
! upshell_assert '' 3> /dev/null
! upshell_assert 0 = 1 3> /dev/null
! upshell_assert X = Y 3> /dev/null
[ "$(upshell_assert true = false 3>&1)" = "Assertion failed: true = false
Failure." ]

# upshell_shell_type

# The correct answer is passed in as an argument to this script.
[ "$(upshell_shell_type)" = "$shell_type" ]

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

[ "$(upshell_hex2ascii 30)" = '0' ]
[ "$(upshell_hex2ascii 40)" = '@' ]
[ "$(upshell_hex2ascii 41)" = 'A' ]

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

upshell_require sh
upshell_require awk
upshell_require tr
! upshell_require exec-not-found-blah 3> /dev/null
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
upshell_delete_cache
[ "$(upshell_list)" = '' ]

[ ! -e "$UPSHELL_CONFIG_HOME"/config ]
[ ! -e "$UPSHELL_CACHE_HOME"/home ]
upshell_add_upshell_module less
[ -e "$UPSHELL_CONFIG_HOME"/config ]
[ -e "$UPSHELL_CACHE_HOME"/home ]
[ 'upshell-module less' = "$(cat "$UPSHELL_CONFIG_HOME"/config)" ]
[ -e "$UPSHELL_CONFIG_HOME"/home/.profile ]

# Assert that we are now sourcing the 'less' module from the '.profile'.
grep "$UPSHELL_CACHE_HOME".\*/less -- "$UPSHELL_CACHE_HOME"/home/.profile
upshell_delete_cache

[ ! -e "$UPSHELL_CACHE_HOME"/home ]
upshell_add_upshell_module nix
[ -e "$UPSHELL_CACHE_HOME"/home ]
[ -e "$UPSHELL_CONFIG_HOME"/home/.profile ]
[ -e "$UPSHELL_CONFIG_HOME"/home/.bashrc ]
[ -e "$UPSHELL_CONFIG_HOME"/home/.bash_profile ]
[ 'upshell-module nix' = "$(cat "$UPSHELL_CONFIG_HOME"/config)" ]

# Assert that we are now sourcing the 'less' module from the '.profile'.
grep "$UPSHELL_CACHE_HOME".\*/nix -- "$UPSHELL_CACHE_HOME"/home/.profile
grep "$UPSHELL_CACHE_HOME".\*/nix -- "$UPSHELL_CACHE_HOME"/home/.bash_profile
grep "$UPSHELL_CACHE_HOME".\*/nix -- "$UPSHELL_CACHE_HOME"/home/.bashrc

# Clearly indicate completion.
echo 'Upshell tests successful!'
