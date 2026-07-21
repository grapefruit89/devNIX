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

    environment.shellAliases = lib.mkIf cfg.aliases (
      lib.mapAttrs (_: lib.mkDefault) {
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
