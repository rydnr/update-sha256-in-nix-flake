# nix/flake.nix
#
# This file packages update-sha256-in-nix-flake as a Nix flake.
#
# Copyright (C) 2023-today rydnr's rydnr/update-sha256-in-nix-flake
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "A dry-wit script to update the sha256 field in a Nix flake";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    dry-wit = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:rydnr/dry-wit/3.0.4?dir=nix";
    };
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "rydnr";
        repo = "update-sha256-in-nix-flake";
        pname = "${org}-${repo}";
        version = "0.0.1";
        pkgs = import nixos { inherit system; };
        description =
          "A dry-wit script to update the sha256 field in a Nix flake";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        update-sha256-in-nix-flake-for = { dry-wit }:
          pkgs.stdenv.mkDerivation rec {
            inherit pname version;
            src = ../.;
            buildInputs = [ dry-wit ];
            phases = [ "unpackPhase" "installPhase" ];

            installPhase = ''
              mkdir -p $out/bin
              cp -r src/* $out/bin
              chmod +x $out/bin/*
              cp README.md LICENSE $out/
              substituteInPlace $out/bin/update-sha256-in-nix-flake.sh \
                --replace "#!/usr/bin/env dry-wit" "#!/usr/bin/env ${dry-wit}/dry-wit"
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        packages = rec {
          default = update-sha256-in-nix-flake-default;
          update-sha256-in-nix-flake-default = update-sha256-in-nix-flake-bash5;
          update-sha256-in-nix-flake-bash5 = update-sha256-in-nix-flake-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-bash5;
          };
          update-sha256-in-nix-flake-zsh = update-sha256-in-nix-flake-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-zsh;
          };
          update-sha256-in-nix-flake-fish = update-sha256-in-nix-flake-for {
            dry-wit = dry-wit.packages.${system}.dry-wit-fish;
          };
        };
      });
}
