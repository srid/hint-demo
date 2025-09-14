{
  perSystem = { config, pkgs, ... }:
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
          ${pkgs.lib.concatMapStringsSep "\n  " (attrs: "export ${attrs}=\"${hintAttrs.${attrs}}\"") (pkgs.lib.attrNames hintAttrs)}
          env | grep ^HINT_
        '';
      };
    };
}
