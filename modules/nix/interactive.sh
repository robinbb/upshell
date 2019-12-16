# modules/nix/interactive.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

[ -z "${UPSHELL_NO_NIX}" ] \
   && [ -d "${HOME}/.nix-profile/share/man" ] \
   && export MANPATH="${HOME}/.nix-profile/share/man${MANPATH:+:}${MANPATH}"
