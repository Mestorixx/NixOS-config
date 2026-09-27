{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Novosibirsk";

  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  security.rtkit.enable = true;

  # Звук и шрифты живут в ../optional/ и подключаются из хоста —
  # здесь их специально нет, чтобы не было дублей.

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  # Очистку мусора и поколений берет на себя nh clean
  system.stateVersion = "24.11";

  programs.nh = {
    enable = true;
    flake = "/home/mestorixx/dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };

  users.users.mestorixx = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };

  services.tailscale.enable = true;
  services.zerotierone.enable = true;

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    gh
    pciutils
    htop
    fastfetch
    unzip
    p7zip
    nftables
    android-tools
    nvd
    nix-output-monitor
  ];
}
