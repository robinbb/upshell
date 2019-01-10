# vim/interactive.sh - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [ -d "$XDG_CONFIG_HOME"/vim ] ; then
   export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc
elif [ -d "$HOME"/.config/vim ] ; then
   export VIMINIT=":source $HOME"/.config/vim/vimrc
fi
export EDITOR=vim
