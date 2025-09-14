# haskell-flake configuration goes in this module.

{ root, inputs, ... }:
{
  imports = [
    inputs.haskell-flake.flakeModule
  ];
  perSystem = { config, self', pkgs, lib, ... }:
    let
      # Create a GHC environment with the packages we need
      hintGhc = config.haskellProjects.default.outputs.finalPackages.ghcWithPackages (ps: with ps; [
        hint-demo-types
        optics-core
        optics-th
      ]);
    in
    {
      # Our only Haskell project. You can have multiple projects, but this template
      # has only one.
      # See https://github.com/srid/haskell-flake/blob/master/example/flake.nix
      haskellProjects.default = {
        # To avoid unnecessary rebuilds, we filter projectRoot:
        # https://community.flake.parts/haskell-flake/local#rebuild
        projectRoot = builtins.toString (lib.fileset.toSource {
          inherit root;
          fileset = lib.fileset.unions [
            (root + /packages)
            (root + /cabal.project)
            (root + /LICENSE)
            (root + /README.md)
          ];
        });

        # Add your package overrides here
        settings = {
          hint-demo = {
            # haddock = false;
            custom = pkg: pkg.overrideAttrs (old: {
              # Set environment variables for include-env during build phase
              preBuild = (old.preBuild or "") + ''
                export HINT_GHC_LIB_DIR="${hintGhc}/lib/ghc-${hintGhc.version}/lib"
                export HINT_GHC_PACKAGE_PATH="${hintGhc}/lib/ghc-${hintGhc.version}/lib/package.conf.d"
              '';
            });
          };
        };

        # What should haskell-flake add to flake outputs?
        autoWire = [ "packages" "apps" "checks" ]; # Wire all but the devShell
      };

      # Default package & app.
      packages.default = self'.packages.hint-demo;
      apps.default = self'.apps.hint-demo;
      devShells.hint = pkgs.mkShell {
        name = "hint-demo-devshell";
        shellHook = ''
          export HINT_GHC_LIB_DIR="${hintGhc}/lib/ghc-${hintGhc.version}/lib";
          export HINT_GHC_PACKAGE_PATH="${hintGhc}/lib/ghc-${hintGhc.version}/lib/package.conf.d";
        '';
      };
    };
}
