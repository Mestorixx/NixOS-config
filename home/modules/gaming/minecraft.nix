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

  polymc = pkgs.stdenv.mkDerivation rec {
    pname = "polymc";
    version = "7.1";
    src = pkgs.fetchurl {
      url = "https://github.com/PolyMC/PolyMC/releases/download/${version}/PolyMC-Linux-amd64-${version}.AppImage";
      hash = "sha256-teTAqhXWkdDrJvvsGeXoeUpX/LbMCTsitLWIXFL4Jgg=";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin $out/opt/polymc $out/share/applications $out/share/icons/hicolor/scalable/apps
      cp $src app.bin
      chmod +x app.bin
      ./app.bin --appimage-extract
      cp -r AppDir $out/opt/polymc/

      cat << EOF > $out/bin/polymc
#!/usr/bin/env bash
exec $out/opt/polymc/AppDir/AppRun "\$@"
EOF
      chmod +x $out/bin/polymc

      cp $out/opt/polymc/AppDir/org.polymc.PolyMC.desktop $out/share/applications/polymc.desktop
      cp $out/opt/polymc/AppDir/org.polymc.PolyMC.svg $out/share/icons/hicolor/scalable/apps/polymc.svg
      sed -i "s|Icon=.*|Icon=polymc|" $out/share/applications/polymc.desktop
      sed -i "s|Exec=.*|Exec=$out/bin/polymc|" $out/share/applications/polymc.desktop
    '';
  };
in
{
  home.packages = with pkgs; [
    temurin-bin-17
    prismlauncher
    polymc
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
