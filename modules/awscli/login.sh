# modules/awscli/login.sh - this is a part of Upshell
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

if [ -e "$XDG_CONFIG_HOME"/aws/credentials ] ; then
   export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
elif [ -e ~/.config/aws/credentials ]; then
   export AWS_SHARED_CREDENTIALS_FILE=~/.config/aws/credentials
else
   # The default made explicit.
   export AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials
fi

if [ -e "$XDG_CONFIG_HOME"/aws/config ] ; then
   export AWS_SHARED_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
elif [ -e ~/.config/aws/config ]; then
   export AWS_SHARED_CONFIG_FILE=~/.config/aws/config
else
   # The default made explicit.
   export AWS_SHARED_CONFIG_FILE=~/.aws/config
fi
