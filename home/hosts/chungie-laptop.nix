{ ... }:

{
  home.username = "mestorixx";
  home.homeDirectory = "/home/mestorixx";
  home.stateVersion = "24.11";

  imports = [
    ../modules/desktop/gnome.nix
    ../modules/desktop/apps.nix
    ../modules/gaming/minecraft.nix
    ../modules/dev
  ];
}
