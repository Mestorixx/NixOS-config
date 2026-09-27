{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    gnome-pomodoro
    flameshot

    # Декларативные расширения GNOME
    gnomeExtensions.appindicator
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
  ];

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "Vitals@CoreCoding.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dash-max-icon-size = 48;
      custom-theme-shrink = true;
      intellihide = true;
      hot-keys = false;
      apply-custom-theme = false;
    };

    # Flameshot: Super+Shift+S
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot" = {
      binding = "<Super><Shift>s";
      command = "flameshot gui";
      name = "Flameshot";
    };
  };
}
