{
  description = "Nix template for Haskell projects";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    haskell-flake.url = "github:srid/haskell-flake/standalone-lib";
  };

  outputs = { nixpkgs, haskell-flake, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      lib = nixpkgs.lib;
      root = ./.;

      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      perSystem = pkgs:
        let
          hflib = haskell-flake.lib { inherit pkgs; };
        in
        rec {
          project = hflib.evalHaskellProject {
            projectRoot = builtins.toString (lib.fileset.toSource {
              inherit root;
              fileset = lib.fileset.unions [
                (root + /packages)
                (root + /cabal.project)
                (root + /LICENSE)
                (root + /README.md)
              ];
            });
            modules = [{
              settings.hint-demo.drvAttrs = hintAttrs;
            }];
          };

          hintGhc = project.finalPackages.ghcWithPackages (ps: [ ps.hint-demo-types ]);
          hintAttrs = rec {
            HINT_GHC_LIB_DIR = "${hintGhc}/lib/${hintGhc.meta.name}/lib";
            HINT_GHC_PACKAGE_PATH = "${HINT_GHC_LIB_DIR}/package.conf.d";
          };
        };
    in
    {
      packages = forAllSystems (pkgs:
        let s = perSystem pkgs;
        in (lib.mapAttrs (_: v: v.package) s.project.packages) // {
          default = s.project.packages.hint-demo.package;
        }
      );

      apps = forAllSystems (pkgs:
        let s = perSystem pkgs;
        in s.project.apps // {
          default = s.project.apps.hint-demo;
        }
      );

      checks = forAllSystems (pkgs:
        (perSystem pkgs).project.checks
      );

      devShells = forAllSystems (pkgs:
        let s = perSystem pkgs;
        in {
          default = pkgs.mkShell {
            name = "hint-demo";
            meta.description = "Haskell development environment";
            inputsFrom = [ s.project.devShell ];
            shellHook = ''
              ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (name: value: "export ${name}=${value}") s.hintAttrs
              )}
              env | grep ^HINT_
            '';
            packages = with pkgs; [
              just
              nixd
              ghciwatch
            ];
          };
        }
      );

    };
}
