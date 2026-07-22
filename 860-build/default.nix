# 860-build — Builds lesbar machen, Pakete ad-hoc ausführen.
#
#   nix-output-monitor (nom)  Build-Fortschritt als Baum statt Textflut.
#                             Aufruf: `nom build …` statt `nix build …`.
#   comma                     Der Befehl IST das Komma: `, <paket> <args>` führt
#                             ein Paket aus, ohne es zu installieren.
#                             ⚠ Braucht die nix-index-Datenbank, um Pakete zu
#                             finden — einmalig `nix-index` laufen lassen, sonst
#                             findet `,` nichts.
#   nh                        Nix-Helper: `nh os switch`, `nh search` — bessere
#                             UX für die üblichen Nix-Befehle.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devNix.build;
in
{
  options.devNix.build.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.devNix.enable;
    description = "Build-Helfer (nix-output-monitor, comma, nh).";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-output-monitor
      comma
      nh
    ];
  };
}
