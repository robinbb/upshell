# modules/default/login.bash - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

add2path() {
   [[ ":$PATH:" =~ ":$1:" ]] || PATH=$1${PATH:+:}$PATH
}
removeFromPath() {
   local p d
   p=":$1:"
   d=":$PATH:"
   d=${d//$p/:}
   d=${d/#:/}
   PATH=${d/%:/}
}
prepend2path() {
   removeFromPath $1
   PATH=$1${PATH:+:}$PATH
}
