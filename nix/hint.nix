{
  perSystem = { config, pkgs, lib, ... }:
    let
      # Create a GHC environment with the packages we need
      hintGhc = config.haskellProjects.default.outputs.finalPackages.ghcWithPackages (ps: with ps; [
        hint-demo-types
      ]);
      # Environment variables required for `hint` to work correctly with our config.hs
      hintAttrs = rec {
        HINT_GHC_LIB_DIR = "${hintGhc}/lib/${hintGhc.meta.name}/lib";
        HINT_GHC_PACKAGE_PATH = "${HINT_GHC_LIB_DIR}/package.conf.d";
      };
    in
    {
      haskellProjects.default = {
        # Add your package overrides here
        settings = {
          hint-demo = {
            drvAttrs = hintAttrs;
          };
        };
      };
      devShells.hint = pkgs.mkShell {
        name = "hint-demo-devshell";
        shellHook = ''
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: "export ${name}=${value}") hintAttrs
          )}
          env | grep ^HINT_
        '';
      };
    };
}
