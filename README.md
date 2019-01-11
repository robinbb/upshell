# Upshell

*Upshell* is an APLv2-licensed shell startup script framework.
[Motivations](https://www.linkedin.com/pulse/bash-startup-scripts-redux-robin-bate-boerop).

## Installation

1. Use your package manager to install GNU Stow. (eg. `brew install stow`)
2. Invoke the following script:
   ```sh
   cd &&
   git clone --depth 1 https://github.com/robinbb/upshell.git .config/upshell &&
   ( cd .config/upshell && stow --target="$HOME" home ) &&
   cd - > /dev/null
   ```
3. Customize by adding lines to `~/.config/upshell/config`.

## Features

- Sane shell configuration using modules
- Compatible with
  [Bash](http://en.wikipedia.org/wiki/Bash_(Unix_shell)) ('bash'),
  the POSIX shell ('sh'),
  the [Bourne shell](http://en.wikipedia.org/wiki/Bourne_shell)
  ('sh'), and the
  [Debian Almquist shell](http://en.wikipedia.org/w/index.php?title=Debian_Almquist_shell)
  ('dash')
- Compatible with 'sftp' and 'scp'
- Out-of-the-box modules for [Nix](http://en.wikipedia.org/wiki/Nix_package_manager)

## Contributions

Contributions are welcome. Please submit a pull request via the
[GitHub issue tracker](https://github.com/robinbb/upshell/issues).
