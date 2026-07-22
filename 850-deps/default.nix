# 850-deps — Abhängigkeiten und Store verstehen.
#
# Werkzeuge für die Frage „warum ist das im Store / warum ändert sich das":
#   nix-tree   interaktiver Baum der Store-Abhängigkeiten
#   nix-diff   Unterschied zweier Store-Pfade — warum ein Rebuild etwas ändert
#   nix-du     Platzverbrauch im Store nach Abhängigkeit
#
# Reine Analyse, kein Betrieb. Eine Domäne (_3–_8), kein Anker — projekteigenes
# Entwicklungswerkzeug, das jeder Nix-Arbeiter braucht, aber keiner im Betrieb.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devNix.deps;
in
{
  options.devNix.deps.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.devNix.enable;
    description = "Store- und Abhängigkeitsanalyse (nix-tree, nix-diff, nix-du).";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nix-tree
      nix-diff
      nix-du
    ];
  };
}
