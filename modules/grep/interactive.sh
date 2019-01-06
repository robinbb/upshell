# modules/grep/interactive.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

upshell_color_grep() {
  grep --colour=auto "$@"
}
alias grep > /dev/null 2>&1 || alias grep=upshell_color_grep
