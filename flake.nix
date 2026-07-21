{
  description = "devNIX -- Werkzeuge und Arbeitsweise fuer die Nix-Entwicklung";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Der eigentliche Zweck: ein importierbares NixOS-Modul.
      nixosModules.default = ./default.nix;
      nixosModules.devNix = ./default.nix;

      # Pruefkonfiguration -- evaluiert das Modul ohne echte Hardware.
      nixosConfigurations.check = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./default.nix
          {
            devNix.enable = true;
            boot.loader.grub.enable = false;
            fileSystems."/" = {
              device = "/dev/null";
              fsType = "ext4";
            };
            system.stateVersion = "25.11";
          }
        ];
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          nixf-diagnose
          statix
          deadnix
          noogle-search
          jq
        ];
      };
    };
}
