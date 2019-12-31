#! default.nix

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

{ pkgs ? import <nixpkgs> {}
}:
let
  formattedShellScript =
    name:
    shellSource:
    pkgs.stdenv.mkDerivation {
      inherit name;
      src = shellSource;
      doCheck = true;
      phases = [ "installPhase" "checkPhase" ];
      installPhase = ''
        # Delete the comment-only lines, and pairs of empty lines.
        cat -s <(sed '/^#.*/d' < $src) > $out
      '';
      checkPhase = ''
        ${pkgs.shfmt}/bin/shfmt -p -i 3 -ci -sr -d $src
        ${pkgs.shellcheck}/bin/shellcheck --norc --shell sh $src
      '';
    };

  exitHandlerInclude =
    formattedShellScript "exit-handler.sh" ./tests/exit_handler.sh;

  upshell =
    formattedShellScript "upshell.inc.sh" ./upshell.inc.sh;

  testScript =
    formattedShellScript "test-upshell" ./tests/upshell.inc.sh;

  bash = "${pkgs.bash}/bin/bash";
  dash = "${pkgs.dash}/bin/dash";
  ksh = "${pkgs.ksh}/bin/ksh";
  zsh = "${pkgs.zsh}/bin/zsh";

  testRunner =
    pkgs.writeScript "upshell-test-runner" ''
      #! /bin/sh
      set -eux
      . ${exitHandlerInclude}

      # Test with Bash first, as it is most familiar and sane.
      ${bash} ${testScript} bash ${upshell}

      # Choose a small docker image with 'git' and a simple POSIX shell.
      docker run --rm \
         -v "${testScript}":/upshell-test \
         -v "${upshell}":/upshell \
         alpine \
         sh -c 'apk add git > /dev/null 2>&1 &&
                sh /upshell-test sh /upshell'
      ${dash} ${testScript} dash ${upshell}
      ${ksh} ${testScript} ksh ${upshell}
      ${zsh} ${testScript} zsh ${upshell}
    '';
in
  { inherit upshell testScript testRunner; }
