# modules/keychain/interactive.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [ -z $UPSHELL_NO_KEYCHAIN ] ; then
   UPSHELL_KEYCHAIN=$(which keychain 2> /dev/null)
   [ $? ] || eval $($UPSHELL_KEYCHAIN --eval)
fi
