# modules/ssh-agent/login.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

which_ssh_agent=$(which ssh-agent)
if [ -n "$which_ssh_agent" ] ; then
   eval $($which_ssh_agent -s -t 3600) > /dev/null
fi
unset -v which_ssh_agent
