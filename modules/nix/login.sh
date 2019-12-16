# modules/nix/login.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

[ -z "${UPSHELL_NO_NIX}" ] \
   && [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ] \
   && . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
