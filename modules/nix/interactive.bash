# modules/nix/interactive.bash - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [[ -z $UPSHELL_NO_NIX \
   && "$NIX_PATH" \
   && -d $HOME/.nix-profile/etc/bash_completion.d \
   ]]
then
   for i in $HOME/.nix-profile/etc/bash_completion.d/* ; do
      [[ -e $i ]] && . $i
   done
fi
