# 800-agents -- KI-Agenten und ihre MCP-Server.
#
# Die MCP-Server werden hier als SYSTEMPAKETE installiert, nicht per
# `nix run` bei jedem Aufruf. Grund: `nix run` auf einen Flake-Ausdruck
# braucht bei jedem Start eine Evaluation und ggf. Netzwerk. Als Paket im
# PATH startet der Server sofort und funktioniert auch offline.
#
# Verdrahtet werden sie NICHT hier -- das macht das Plugin unter
# plugins/devnix-agent/.mcp.json. Dieses Modul stellt nur die Binaries.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devNix.agents;
in
{
  options.devNix.agents = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.devNix.enable;
      description = "Claude Code und die MCP-Server installieren.";
    };

    claudeCode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Claude Code CLI installieren.

        ACHTUNG: unfree. Dieses Modul setzt KEIN globales allowUnfree, sondern
        gibt nur dieses eine Paket frei -- siehe nixpkgs.config unten. Ein
        globales allowUnfree waere eine Entscheidung, die dem Betreiber gehoert,
        nicht uns.
      '';
    };

    mcpServer = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "nixos"
        "context7"
        "github"
      ];
      description = ''
        Welche MCP-Server installiert werden.

        nixos    -- nixpkgs-Pakete, services.*-Optionen, Noogle, nix.dev
        context7 -- Bibliotheksdokumentation (Caddy, systemd, APIs)
        github   -- Issues und PRs, bevor ein Fremdpaket-Fehler debuggt wird
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Nur dieses eine Paket freigeben, kein globales allowUnfree.
    #
    # mkDefault ist hier PFLICHT, nicht Geschmack: allowUnfreePredicate ist ein
    # einzelnes Attribut. Setzt der Betreiber es ebenfalls -- und das tut fast
    # jeder, der irgendein unfreies Paket braucht -- kollidieren beide bei
    # gleicher Prioritaet. Das NixOS-Modulsystem meldet dann einen Fehler, es
    # gibt KEIN "letzter gewinnt".
    #
    # Mit mkDefault (Prioritaet 1000) gewinnt die Festlegung des Betreibers
    # (100) sauber. Auf q958 ist das unfree.nix, die unrar UND claude-code
    # freigibt.
    #
    # Die Assertion unten faengt den verbleibenden Fall ab: der Betreiber setzt
    # ein eigenes Praedikat, das claude-code NICHT enthaelt. Dann schlaegt der
    # Build sonst mit einer Meldung fehl, die nicht auf devNIX zeigt.
    nixpkgs.config.allowUnfreePredicate = lib.mkDefault (
      pkg: builtins.elem (lib.getName pkg) (lib.optional cfg.claudeCode "claude-code")
    );

    environment.systemPackages =
      lib.optional cfg.claudeCode pkgs.claude-code
      ++ lib.optional (builtins.elem "nixos" cfg.mcpServer) pkgs.mcp-nixos
      ++ lib.optional (builtins.elem "context7" cfg.mcpServer) pkgs.context7-mcp
      ++ lib.optional (builtins.elem "github" cfg.mcpServer) pkgs.github-mcp-server;

    assertions = [
      {
        assertion =
          !cfg.claudeCode || (config.nixpkgs.config.allowUnfreePredicate or (_: false)) pkgs.claude-code;
        message = ''
          devNix.agents.claudeCode ist an, aber claude-code ist nicht als unfree
          freigegeben.

          Das passiert, wenn die Host-Konfiguration ein eigenes
          nixpkgs.config.allowUnfreePredicate setzt -- dieses gewinnt gegen
          devNIX (mkDefault) und muss claude-code dann selbst enthalten:

              nixpkgs.config.allowUnfreePredicate =
                pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

          Alternativ devNix.agents.claudeCode = false setzen.
        '';
      }
      {
        assertion = builtins.all (
          s:
          builtins.elem s [
            "nixos"
            "context7"
            "github"
          ]
        ) cfg.mcpServer;
        message = ''
          devNix.agents.mcpServer kennt nur: nixos, context7, github.
          Ein unbekannter Name waere still wirkungslos -- deshalb bricht der
          Build hier ab, statt einen fehlenden Server zu verschweigen.
        '';
      }
    ];
  };
}
