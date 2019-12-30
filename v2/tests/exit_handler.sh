#! tests/exit_handler.sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

exit_handler() {
   EXIT_CODE="$?"
   if [ "$EXIT_CODE" -eq 0 ]; then
      echo "All shells passed the tests!"
   else
      echo "Testing failed."
   fi
   return "$EXIT_CODE"
}

trap exit_handler EXIT
