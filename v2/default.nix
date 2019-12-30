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
      '';
    };

  exitHandlerInclude =
    formattedShellScript "exit-handler.sh" ./tests/exit_handler.sh;

  upshell =
    formattedShellScript "upshell.inc.sh" ./upshell.inc.sh;

  testScript =
    formattedShellScript "test-upshell" ./tests/upshell.inc.sh;

  ksh = "${pkgs.ksh}/bin/ksh";
  bash = "${pkgs.bash}/bin/bash";
  zsh = "${pkgs.zsh}/bin/zsh";
  dash = "${pkgs.dash}/bin/dash";
  testRunner = pkgs.writeScript "upshell-test-runner" ''
    #! /bin/sh
    set -eux
    . ${exitHandlerInclude}
    ${dash} ${testScript} dash ${upshell}
    ${ksh} ${testScript} ksh ${upshell}
  '';
in
  testRunner
