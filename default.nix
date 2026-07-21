# devNIX -- Sammelmodul.
#
# Bindet alle Ordner mit dreistelliger Nummer automatisch ein. Ein neuer
# Werkzeugblock = ein neuer Ordner, kein Eintrag hier.
#
# Warum Auto-Import gefahrlos ist: das NixOS-Modulsystem ist
# REIHENFOLGEUNABHAENGIG. Bei gleicher Priorität gibt es einen Konflikt, kein
# "letzter gewinnt" -- empirisch geprueft in mediNix (ADR-5042). Sortiert wird
# nur, damit Fehlermeldungen in nachvollziehbarer Reihenfolge erscheinen.
{ lib, ... }:
let
  hier = builtins.readDir ./.;

  istModulOrdner = name: typ: typ == "directory" && builtins.match "^[0-9]{3}-.*" name != null;

  ordner = lib.sort (a: b: a < b) (builtins.attrNames (lib.filterAttrs istModulOrdner hier));
in
{
  imports = map (n: ./. + "/${n}") ordner;

  options.devNix.enable = lib.mkEnableOption ''
    die devNIX-Werkzeugsammlung.

    Schaltet alle Bloecke gemeinsam ein. Einzelne Bloecke lassen sich danach
    gezielt wieder abschalten, z. B. devNix.shell.enable = false
  '';
}
