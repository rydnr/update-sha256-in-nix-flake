# update-sha256-in-nix-flake

A simple dry-wit script to update the sha256 field in a Nix flake.

Given a Nix flake with an entry such as

``` sh
[..]
      version = "...";
      sha256 = "...";
[..]
```

this script uses `nix-prefetch-url` to get the sha256 value and update the flake for you. 

## Usage

``` sh
update-sha256-in-nix-flake.sh [-v|--debug] [-vv|--trace] [-q|--quiet] [-h|--help] -V|--version arg [-f|--flake arg]
Copyleft 2023-today Automated Computing Machinery S.L.
Distributed under the terms of the GNU General Public License v3

Updates the version and sha256 hash of a PythonEDA-specific Nix flake

Where:
  * -v|--debug: Display debug messages. Optional.
  * -vv|--trace: Display trace messages. Optional.
  * -q|--quiet: Be silent. Optional.
  * -h|--help: Display information about how to use the script. Optional.
  * -V|--version arg: The version. Mandatory.
  * -f|--flake arg: The Nix flake. Mandatory.
```


