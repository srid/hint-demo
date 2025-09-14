{
  perSystem = { config, pkgs, ... }:
    let
      # Create a GHC environment with the packages we need
      hintGhc = config.haskellProjects.default.outputs.finalPackages.ghcWithPackages (ps: with ps; [
        hint-demo-types
        optics-core
        optics-th
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
      devShells.hint = pkgs.mkShell (hintAttrs // {
        name = "hint-demo-devshell";
      });
    };
}
