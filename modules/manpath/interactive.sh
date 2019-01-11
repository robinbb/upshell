# manpath/interactive.sh - part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

for dir in /usr/share/man \
           /usr/local/man \
           /usr/local/share/man
do
   if [ -d "$dir" ] ; then
      export MANPATH=$dir${MANPATH:+:}"$MANPATH"
   fi
done
