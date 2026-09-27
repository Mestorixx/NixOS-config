{ pkgs, ... }:

let
  pirateLauncher = pkgs.stdenv.mkDerivation {
    pname = "pirate-launcher";
    version = "1.40.3";
    src = pkgs.fetchurl {
      url = "https://llaun.ch/jar";
      hash = "sha256-Cbp1F8ipsweA/5pt4jC4kFJHg1rg2pFNZpkeKztLbE4=";
    };
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out/share/java $out/bin
      cp $src $out/share/java/launcher.jar
      makeWrapper ${pkgs.temurin-bin-17}/bin/java $out/bin/pirate-launcher \
        --add-flags "-jar $out/share/java/launcher.jar"
    '';
  };
in
{
  home.packages = with pkgs; [
    temurin-bin-17
    temurin-bin-21
    prismlauncher
    pirateLauncher
  ];

  xdg.desktopEntries.pirate-launcher = {
    name = "Minecraft (KLauncher)";
    exec = "pirate-launcher";
    terminal = false;
    categories = [ "Game" ];
    icon = "applications-games";
  };
}
