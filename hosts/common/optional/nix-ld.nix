{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    glib
    gtk3
    atk
    at-spi2-atk
    cairo
    pango
    gdk-pixbuf
    dbus
    nss
    nspr
    alsa-lib
    expat
    libdrm
    libgbm
    mesa
    libxshmfence
    systemd
    cups
    desktop-file-utils
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libx11
    libxcb
    libxcursor
    libxi
    libglvnd
    libxkbcommon
    wayland
    vulkan-loader
  ];
}
