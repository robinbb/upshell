# modules/default/interactive.bash - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Set UPSHELL_GNU_LS according to whether we are using GNU ls.
ls --version 2> /dev/null
export UPSHELL_GNU_LS=$?

# Create the `upsh_color_ls` alias according to UPSHELL_GNU_LS.
if [ -z $UPSHELL_GNU_LS ] ; then
   alias upsh_color_ls='ls --color=auto'
else
   alias upsh_color_ls='ls -G'
fi

# Set some common aliases if not already set.
[ alias la &> /dev/null ] || alias la='upsh_color_ls -a'
[ alias ll &> /dev/null ] || alias ll='upsh_color_ls -la'

# Set some useful environment variables if not already set.
export EDITOR=${EDITOR:-vi}
