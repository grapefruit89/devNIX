# 810-nix-tools -- Formatierung, Linting, Nachschlagen.
#
# WELCHES WERKZEUG UND WARUM GENAU DIESES (geprueft am 2026-07-21 gegen
# nixpkgs selbst, nicht aus dem Gedaechtnis):
#
#   nixfmt 1.4      Formatierung. "Official formatter for Nix code" und das,
#                   was nixpkgs' eigene CI benutzt (ci/treefmt.nix).
#   nixf-diagnose   Semantische Analyse (ungenutzte Bindungen, Primops).
#                   Ebenfalls in nixpkgs' ci/treefmt.nix.
#   statix          Stil-Vorschlaege. Community, NICHT in der nixpkgs-CI.
#   deadnix         Toter Code. Community, NICHT in der nixpkgs-CI.
#   noogle-search   lib.*- und builtins.*-Funktionen mit Signatur und Beispiel.
#   shellcheck      Shell-Skripte. Gehoert hierher, obwohl es kein Nix-Werkzeug
#                   ist: sobald ein Projekt Hooks oder Helfer mitliefert, ist
#                   Shell Teil des Produkts. Am 2026-07-21 aufgefallen -- die
#                   Nix-Dateien waren sauber, die Hook-Skripte ungeprueft.
#   shfmt           Formatierung fuer Shell, das Gegenstueck zu nixfmt.
#
# NICHT nixfmt-rfc-style verwenden: seit 2025-07-14 nur noch ein Alias
# ("is now the same as pkgs.nixfmt which should be used instead",
# pkgs/top-level/aliases.nix). Store-Pfade sind bitgleich.
# nixfmt-classic ist entfernt. nixpkgs-fmt ist Community mit einem Maintainer
# und nicht das, was nixpkgs selbst fahrt.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devNix.nixTools;
in
{
  options.devNix.nixTools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.devNix.enable;
      description = "Nix-Formatierung, Linting und Nachschlagewerkzeuge.";
    };

    languageServer = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "nixd"
          "nil"
        ]
      );
      default = "nixd";
      description = ''
        Welcher Nix-Language-Server, oder null fuer keinen.

        nixd -- kann gegen die EIGENE Konfiguration auswerten und kennt damit
                die tatsaechlich vorhandenen Optionen. Aus derselben Familie
                wie nixf-diagnose.
        nil  -- leichter, rein statisch, keine Auswertung.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      (with pkgs; [
        nixfmt
        nixf-diagnose
        statix
        deadnix
        noogle-search
        shellcheck
        shfmt
      ])
      ++ lib.optional (cfg.languageServer == "nixd") pkgs.nixd
      ++ lib.optional (cfg.languageServer == "nil") pkgs.nil;

    # Kurzbefehl fuer die vollstaendige Kette. Bewusst als Shell-Alias und
    # nicht als Skript: er soll im Repo-Verzeichnis laufen, das der Mensch
    # gerade offen hat -- ein Skript muesste den Pfad raten.
    environment.shellAliases.nixcheck = lib.mkOverride 900 (
      "NIXFILES=$(find . -name '*.nix' -not -path './.git/*') && "
      + "nixfmt $NIXFILES && "
      + "nixf-diagnose --ignore=sema-unused-def-lambda-noarg-formal $NIXFILES && "
      + "statix check . && "
      + "deadnix --fail . && "
      # Shell mitpruefen, wenn welche da ist. Ohne -r kein Fehler bei 0 Treffern.
      + "{ SH=$(find . -name '*.sh' -not -path './.git/*'); "
      + "[ -n \"$SH\" ] && shellcheck $SH || true; }"
    );
  };
}
