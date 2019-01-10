# tmux/interactive.sh - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

tmux() {
  if [ -d "$XDG_CONFIG_HOME"/tmux ] ; then
     tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf "$@"
  elif [ -d "$HOME"/.config/tmux ] ; then
     tmux -f "$HOME"/.config/tmux/tmux.conf "$@"
  else
     tmux "$@"
  fi
}

if [ "$XDG_RUNTIME_DIR" ] ; then
   export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
fi
