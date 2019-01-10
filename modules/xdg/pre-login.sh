# modules/xdg/pre-login.sh - part of Upshell
#
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Add support for https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}

export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-'/etc/xdg'}
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-'/usr/local/share:/usr/share'}
