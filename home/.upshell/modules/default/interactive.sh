# modules/default/interactive.bash - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

case $(ls --version 2> /dev/null) in
   *GNU*) alias colorls='ls --color=auto' ;;
   *)     alias colorls='ls -G' ;;
esac
alias l='colorls -a'
alias ll='colorls -la'
export EDITOR='vi'
