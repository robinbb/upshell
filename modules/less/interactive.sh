# modules/less/interactive.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [ "$XDG_CACHE_HOME" ] ; then
   mkdir -p "$XDG_CACHE_HOME"/less
   export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
   export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
else
   mkdir -p ~/.cache/less
   export LESSKEY=~/.cache/less/lesskey
   export LESSHISTFILE=~/.cache/less/history
fi
