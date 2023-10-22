{
  description = "binpack2d";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      perSystem = system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };

          haskellPackages = pkgs.haskellPackages.override {
            overrides = self: super: {
              # h-raylib =
              #   pkgs.haskell.lib.doJailbreak
              #     (pkgs.haskell.lib.unmarkBroken super.h-raylib);
              # haskell-language-server = pkgs.haskell.lib.compose.disableCabalFlag "ormolu" super.haskell-language-server;
              # ormolu = super.fourmolu;
              # hls-ormolu-plugin = super.hls-fourmolu-plugin;
            };
          };

          jailbreakUnbreak = pkg:
            pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

          packageName = "h-raylib-examples";
        in
        {
          packages.${packageName} = # (ref:haskell-package-def)
            haskellPackages.callCabal2nix packageName ./. rec {
              # Dependency overrides go here
            };

          defaultPackage = inputs.self.packages.${system}.${packageName};
          devShell = inputs.self.packages.${system}.${packageName}.env.overrideAttrs (oldEnv: { buildInputs = oldEnv.buildInputs ++ [ haskellPackages.haskell-language-server ]; });
        };
    in
    inputs.flake-utils.lib.eachDefaultSystem perSystem;
}