# Upshell

Upshell is an APLv2-licensed shell startup script framework.
[Motivations](https://www.linkedin.com/pulse/bash-startup-scripts-redux-robin-bate-boerop).

## Installation

1. Use your package manager to install GNU Stow. (eg. `brew install stow`)
2. Invoke the following script:
   ```sh
   cd &&
   git clone --depth 1 https://github.com/robinbb/upshell.git .upshell &&
   cd .upshell &&
   stow home
   ```
4. Customize by adding scripts to `~/.upshell/config` and linking modules to
   the `~/.upshell/modules` directory.

## Features

- Works with
- Compatible with
  [Bash](http://en.wikipedia.org/wiki/Bash_(Unix_shell)),
  the POSIX shell,
  the [Bourne shell](http://en.wikipedia.org/wiki/Bourne_shell)
  ('sh'), and the
  [Debian Almquist shell](http://en.wikipedia.org/w/index.php?title=Debian_Almquist_shell)
  ('dash')
- Sane configuration using modules
- Compatible with 'sftp' and 'scp'
- Out-of-the-box modules for [Nix](http://en.wikipedia.org/wiki/Nix_package_manager)

## Contributions

Contributions are welcome. Please submit a pull request via the
[GitHub issue tracker](https://github.com/robinbb/upshell/issues).
