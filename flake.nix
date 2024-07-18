{
  description = "DB tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    rec {
      packages.${system}.default = pkgs.symlinkJoin {
        name = "db-tools";
        paths = [
          (import ./bin/schema.nix {
            inherit pkgs;
            name = ":dbschema";
          })
          (import ./bin/cluster.nix {
            inherit pkgs nixpkgs;
            name = ":dbstart";
          })
          (import ./bin/cli.nix {
            inherit pkgs nixpkgs;
            name = ":dbcli";
          })
          (import ./bin/dump.nix {
            inherit pkgs nixpkgs;
            name = ":dbdump";
          })
        ];
      };

      devShells.x86_64-linux.default = pkgs.mkShell { buildInputs = [ packages.${system}.default ]; };
    };
}
