{ config, pkgs, ... }:

{
  imports = [
    ../common/global
    ../common/optional/pipewire.nix
    ../common/optional/fonts.nix
    ../common/optional/hardware-nvidia-prime.nix
    ../common/optional/nix-ld.nix
    ../common/optional/zapret.nix
    # Настоящий файл железа сюда положит install.sh при установке.
    ./hardware-configuration.nix
  ];

  networking.hostName = "chungie-laptop";

  # Ноут работает с закрытой крышкой — не засыпать при закрытии
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

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
    gamescopeSession.enable = true;
  };

  # GameMode: при запуске игры поднимает приоритет CPU/GPU, отключает фоновые задачи
  programs.gamemode.enable = true;

  # Gamescope: изолированный Wayland-композитор для игр, убирает фризы и разрывы
  programs.gamescope = {
    enable = true;
    capSysNice = true; # позволяет gamescope выставлять nice -20
  };


  # Возвращаем v2rayA в систему как обычное приложение
  # mangohud — оверлей с FPS/GPU/CPU прямо в игре (как MSI Afterburner на винде)
  environment.systemPackages = with pkgs; [ v2raya mangohud ];

  # Включение системного демона v2rayA (создает unit в systemd и веб-интерфейс)
  services.v2raya.enable = true;

  # Системный демон для Happ (запускается от root, обеспечивает TUN-режим)
  systemd.services.happd = {
    description = "Happ Proxy Client Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.writeShellScript "happd" ''
        export LD_LIBRARY_PATH="/home/mestorixx/.local/share/happ/lib:''${LD_LIBRARY_PATH:-}"
        exec /home/mestorixx/.local/share/happ/bin/happd
      ''}";
      Restart = "always";
      RestartSec = "3s";
    };
  };

  # Тюнинг под ZRAM: убирает микрофризы, мгновенный отклик при нехватке памяти
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "kernel.sched_autogroup_enabled" = 1;
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

  # ── Оптимизации I/O и отзывчивости ──

  # noatime: не писать время последнего чтения файла → меньше нагрузки на SSD
  fileSystems."/".options = [ "noatime" ];

  # I/O scheduler: mq-deadline легче для SSD, чем дефолтный bfq
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';

  # /tmp в RAM — ускоряет временные файлы, не трогает SSD
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  # Распределение прерываний по ядрам — убирает микрофризы
  services.irqbalance.enable = true;

  # ── Сеть ──

  # Отключить WiFi powersave — убирает задержки и пинг-спайки
  networking.networkmanager.wifi.powersave = false;

  # Не ждать сеть при загрузке — ускоряет boot на 5-10 сек
  systemd.services.NetworkManager-wait-online.enable = false;

  # Лимит systemd journal — не разрастается, не жрёт I/O
  services.journald.settings.Journal.SystemMaxUse = "100M";

}


