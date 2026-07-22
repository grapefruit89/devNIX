{
  description = "devNIX -- Werkzeuge und Arbeitsweise fuer die Nix-Entwicklung";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;

      # Kleiner Helfer: ein Check, der ein Werkzeug ueber dem Repo laufen laesst.
      # --check/--fail aendert nichts, es meldet nur -> CI wird rot, nie der Baum.
      mkCheck =
        name: deps: script:
        pkgs.runCommand "check-${name}" { nativeBuildInputs = deps; } ''
          cd ${self}
          ${script}
          touch $out
        '';
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

      # ── Ratsche ──────────────────────────────────────────────────────────
      # Genau wie mediNix: `nix flake check` faengt Fehler, bevor sie
      # ausgerollt werden. Ohne diese Sektion blieb der allowUnfreePredicate-
      # Eval-Fehler monatelang unbemerkt -- es gab schlicht keinen Check.
      checks.${system} = {

        # 1. Evaluiert und baut das Modul ueberhaupt? (fing den Eval-Fehler)
        eval = self.nixosConfigurations.check.config.system.build.toplevel;

        # 2. Ist alles formatiert? --check aendert nichts, es meldet nur.
        format = mkCheck "format" [ pkgs.nixfmt ] ''
          nixfmt --check $(find . -name '*.nix' -not -path './.git/*') \
            || { echo ""; echo "Nicht formatiert. Beheben mit:  nix fmt"; exit 1; }
        '';

        # 3. Anti-Patterns: baut zwar, ist aber schwer lesbar.
        statix = mkCheck "statix" [ pkgs.statix ] ''
          statix check . \
            || { echo ""; echo "Beheben mit:  statix fix ."; exit 1; }
        '';

        # 4. Toter Code.
        deadnix = mkCheck "deadnix" [ pkgs.deadnix ] ''
          deadnix --fail . \
            || { echo ""; echo "Beheben mit:  deadnix --edit ."; exit 1; }
        '';

        # 5. DIE RATSCHE -- Dezimalrahmen-Invarianten (ADR-8000).
        # ═══════════════════════════════════════════════════════════════
        # devNIX ist das Projekt "800". Es hat keine Dienste/Ports/UIDs wie
        # mediNix -- die Invariante hier ist die ORDNERNUMMERIERUNG:
        #   * jeder Modulordner fuehrt mit der Projektziffer 8
        #   * 800 ist das Fundament (die Repo-Wurzel selbst), nie ein Ordner
        #   * keine doppelten Nummern
        # Faengt eine falsch nummerierte Domaene beim `nix flake check`.
        dezimalrahmen =
          let
            eintraege = builtins.readDir ./.;
            istModul = name: typ: typ == "directory" && builtins.match "^[0-9]{3}-.*" name != null;
            ordner = builtins.attrNames (lib.filterAttrs istModul eintraege);
            nummer = name: lib.toInt (builtins.head (builtins.match "^([0-9]{3})-.*" name));
            nums = map nummer ordner;
            verstoesse = lib.filter (v: v != null) (
              map (
                name:
                let
                  num = nummer name;
                  projekt = num / 100;
                  probleme = lib.concatStringsSep ", " (
                    lib.optional (projekt != 8) "fuehrende Ziffer ${toString projekt} != 8"
                    ++ lib.optional (num == 800) "800 ist das Fundament (Repo-Wurzel), kein Modulordner"
                  );
                in
                if probleme == "" then null else "${name}: ${probleme}"
              ) ordner
            );
            fehler =
              verstoesse
              ++ lib.optional (
                lib.length nums != lib.length (lib.unique nums)
              ) "doppelte Nummern in den Modulordnern";
          in
          if fehler == [ ] then
            pkgs.runCommand "dezimalrahmen-ok" { } "echo 'ADR-8000 eingehalten' > $out"
          else
            throw ("ADR-8000 (Dezimalrahmen) verletzt:\n  " + lib.concatStringsSep "\n  " fehler);
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
