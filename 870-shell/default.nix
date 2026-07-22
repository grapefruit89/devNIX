# 820-shell -- Kommandozeilenwerkzeuge, auf die sich die Anleitungen berufen.
#
# Diese Liste ist kein Geschmacksthema. Jedes Werkzeug hier wird in einer
# Anleitung oder einem Hook namentlich aufgerufen -- fehlt eines, bricht die
# Anleitung still.
#
# jq ist der wichtigste Eintrag: die Hooks des Plugins lesen ihre Eingabe als
# JSON von stdin und brauchen jq zwingend. Ohne jq laufen sie ins Leere und
# alle Sperren sind wirkungslos, ohne dass es auffaellt.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devNix.shell;
in
{
  options.devNix.shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.devNix.enable;
      description = "Kommandozeilenwerkzeuge fuer die Entwicklung.";
    };

    aliases = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Aliase fuer die modernen Ersatzwerkzeuge setzen (cat->bat, ls->eza, ...).

        Als mkDefault gesetzt -- der Betreiber kann jeden einzelnen ueberschreiben.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jq # PFLICHT: die Plugin-Hooks brauchen es
      gh # GitHub-CLI, u. a. fuer den GitHub-MCP
      ripgrep
      fd
      bat
      eza
      btop
      dust
      duf
    ];

    # PRIORITAET 900, nicht mkDefault -- und das ist keine Feinheit:
    #
    # nixpkgs setzt selbst Aliase per mkDefault (nixos/modules/config/
    # shells-environment.nix, z. B. ll = "ls -l"). Zwei mkDefault sind
    # GLEICHRANGIG, und das Modulsystem meldet dann einen Konflikt -- es gibt
    # kein "letzter gewinnt":
    #
    #   The option `environment.shellAliases.ll' has conflicting definitions:
    #     - In `.../820-shell': "eza --icons --git -la"
    #     - In `.../shells-environment.nix': "ls -l"
    #
    # Am 2026-07-21 ist genau daran der erste Switch gescheitert.
    #
    # mkOverride 900 liegt zwischen beidem: es schlaegt nixpkgs' mkDefault
    # (1000), verliert aber gegen eine normale Zuweisung des Betreibers (100)
    # und erst recht gegen mkForce (50). Genau die gewuenschte Rangfolge --
    # wir korrigieren die Distribution, nicht den Menschen.
    environment.shellAliases = lib.mkIf cfg.aliases (
      lib.mapAttrs (_: lib.mkOverride 900) {
        cat = "bat --paging=never";
        ls = "eza --icons --git";
        ll = "eza --icons --git -la";
        find = "fd";
        grep = "rg";
        du = "dust";
        df = "duf";
        top = "btop";
      }
    );
  };
}
