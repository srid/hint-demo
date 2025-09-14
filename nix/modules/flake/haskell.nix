# haskell-flake configuration goes in this module.

{ root, inputs, ... }:
{
  imports = [
    inputs.haskell-flake.flakeModule
  ];
  perSystem = { self', lib, config, pkgs, ... }: {
    # Our only Haskell project. You can have multiple projects, but this template
    # has only one.
    # See https://github.com/srid/haskell-flake/blob/master/example/flake.nix
    haskellProjects.default = {
      # To avoid unnecessary rebuilds, we filter projectRoot:
      # https://community.flake.parts/haskell-flake/local#rebuild
      projectRoot = builtins.toString (lib.fileset.toSource {
        inherit root;
        fileset = lib.fileset.unions [
          (lib.fileset.maybeMissing (root + /packages))
          (lib.fileset.maybeMissing (root + /cabal.project))
          (lib.fileset.maybeMissing (root + /LICENSE))
          (lib.fileset.maybeMissing (root + /README.md))
        ];
      });

      # The base package set (this value is the default)
      # basePackages = pkgs.haskellPackages;

      # Packages to add on top of `basePackages`
      packages = {
        # Add source or Hackage overrides here
        # (Local packages are added automatically)

        # Force hint to be rebuilt with current package set to avoid package ID mismatches
        hint.source = "0.9.0.8"; # Use Hackage version but rebuild with current deps

        /*
        aeson.source = "1.5.0.0" # Hackage version
        shower.source = inputs.shower; # Flake input
        */
      };

      # Add your package overrides here
      settings = {
        hint-demo = { self, super, ... }: {
          stan = true;
          # haddock = false;
          # Fix hint package database issues by ensuring it finds the correct GHC environment
          custom = pkg:
            let
              # Create a GHC environment with all the packages hint needs
              ghcWithPackages = super.ghcWithPackages (ps: with ps; [
                base
                aeson
                async
                data-default
                directory
                filepath
                hint
                mtl
                optics-core
                profunctors
                relude
                shower
                time
                with-utf8
                hint-demo-types
              ]);
            in
            pkg.overrideAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                pkgs.makeWrapper
              ];
              postInstall = (old.postInstall or "") + ''
                # Wrap the executable to set GHC_LIB_DIR for hint library
                wrapProgram $out/bin/hint-demo \
                  --set GHC_LIB_DIR "${super.ghc}/lib/ghc-${super.ghc.version}/lib" \
                  --set GHC_PACKAGE_PATH "${ghcWithPackages}/lib/ghc-${super.ghc.version}/lib/package.conf.d"
              '';
            });
        };
        hint-demo-types = {
          stan = true;
        };
        hint = {
          check = false; # Disable tests to avoid Nix build issues
        };

        /*
        aeson = {
          check = false;
        };
        */
      };

      # What should haskell-flake add to flake outputs?
      autoWire = [ "packages" "apps" "checks" ]; # Wire all but the devShell
    };

    # Default package & app.
    packages.default = self'.packages.hint-demo;
    apps.default = self'.apps.hint-demo;
  };
}
