{ config, pkgs, ... }:

{
  imports = [
    ../common/global
    ../common/optional/pipewire.nix
    ../common/optional/fonts.nix
    ../common/optional/hardware-nvidia-prime.nix
    ../common/optional/zapret.nix
    ../common/optional/nix-ld.nix
    # Настоящий файл железа сюда положит install.sh при установке.
    ./hardware-configuration.nix
  ];

  networking.hostName = "chungie-laptop";

  # LTS-ядро вместо latest: MX110 (Maxwell) + проприетарный драйвер
  # регулярно ломаются на самых свежих ядрах. На LTS ноут тише и стабильнее.
  boot.kernelPackages = pkgs.linuxPackages;

  # Не вешать 2 ядра / 8 ГБ при сборке пакетов.
  nix.settings.max-jobs = 2;
  nix.settings.cores = 2;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    enableNotifications = true;
  };

  services.thermald.enable = true;
  services.fstrim.enable = true;

  # Питание: только power-profiles-daemon (профили в трее GNOME).
  # cpuFreqGovernor специально не трогаем, чтобы не конфликтовать с ним.
  services.power-profiles-daemon.enable = true;

  # Фоновые индексаторы GNOME жрут слабый CPU — выключены.
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    extraPackages = with pkgs; [ tetrio-desktop ];
  };


  # Возвращаем v2rayA в систему как обычное приложение
  environment.systemPackages = with pkgs; [ v2raya ];

  # Включение системного демона v2rayA (создает unit в systemd и веб-интерфейс)
  services.v2raya.enable = true;

  # Тюнинг под ZRAM: убирает микрофризы, мгновенный отклик при нехватке памяти
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # Аппаратное декодирование видео через Intel HD 620 (разгружает CPU на YouTube/видео)
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
  ];

  # ananicy-cpp с правилами CachyOS: держит интерфейс плавным даже под нагрузкой
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
}


