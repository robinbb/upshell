# manpath/interactive.sh - part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

for dir in /usr/share/man \
           /usr/local/man \
           /usr/local/share
do
   export MANPATH=$dir${MANPATH:+:}"$MANPATH"
done

export MANPATH=/usr/local/share/man:/usr/share/man${MANPATH:+:}"$MANPATH"
export MANPATH=/usr/local/share/man:/usr/share/man${MANPATH:+:}"$MANPATH"
