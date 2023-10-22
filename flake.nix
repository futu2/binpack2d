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
            overrides = self: super: { };
          };

          jailbreakUnbreak = pkg:
            pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

          packageName = "binpack2d";
        in
        {
          packages.${packageName} = haskellPackages.callCabal2nix packageName ./. { };
          defaultPackage = inputs.self.packages.${system}.${packageName};
          devShell = inputs.self.packages.${system}.${packageName}.env.overrideAttrs (oldEnv: { buildInputs = oldEnv.buildInputs ++ [ haskellPackages.haskell-language-server ]; });
        };
    in
    inputs.flake-utils.lib.eachDefaultSystem perSystem;
}
