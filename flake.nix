{
  description = "NixOS VSCodium server";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      nixosModule = self.nixosModules.default; # Deprecrated, but perhaps still in use.
      nixosModules.default = import ./modules/vscodium-server;
      nixosModules.home = self.homeModules.default; # Backwards compatiblity.
      homeModules.default = import ./modules/vscodium-server/home.nix; # Consistent with homeConfigurations.
    }
    // (let
      inherit (flake-utils.lib) defaultSystems eachSystem;
    in
      eachSystem defaultSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.lib) hasSuffix optionalAttrs;
        auto-fix-vscodium-server = pkgs.callPackage ./pkgs/auto-fix-vscodium-server.nix { };
      in
        # The package depends on `inotify-tools` which is only available on Linux.
        optionalAttrs (hasSuffix "-linux" system) {
          packages = {
            inherit auto-fix-vscodium-server;
            default = auto-fix-vscodium-server;
          };
          checks = {
            inherit auto-fix-vscodium-server;
          };
        }));
}
