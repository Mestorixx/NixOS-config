# /etc/nixos/configuration.nix
# Конфигурация для NixOS с GNOME, Steam, гибридной графикой NVIDIA, Flatpak и софтом.

{ config, pkgs, ... }:

{
  imports =
    [
      # ВНИМАНИЕ: Оставьте эту строку как есть, она подключает сгенерированный
      # конкретно под ваше железо файл со списком дисков и модулей ядра:
      ./hardware-configuration.nix
    ];

  # ==========================================
  # Загрузчик (Bootloader - UEFI / systemd-boot)
  # ==========================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # хранить до 10 поколений в меню загрузки

  # Современное ядро Linux (рекомендуется для свежих ноутбуков)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==========================================
  # Сеть и локализация
  # ==========================================
  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Moscow"; # При необходимости замените на ваш часовой пояс (например, "Asia/Novokuznetsk")

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

  # ==========================================
  # Графическая оболочка: GNOME Desktop
  # ==========================================
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Настройка горячей клавиши Super + Shift + S для Flameshot (как в Windows)
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.media-keys]
    custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/']

    [org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.flameshot]
    binding='<Super><Shift>s'
    command='flameshot gui'
    name='Flameshot'
  '';

  # Раскладка клавиатуры (переключение через Win+Space или Alt+Shift)
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  # ==========================================
  # Звук и мультимедиа (PipeWire)
  # ==========================================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==========================================
  # Bluetooth (для наушников и колонок)
  # ==========================================
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ==========================================
  # Шрифты (JetBrains Mono + Emoji)
  # ==========================================
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono  # со значками и иконками для терминала/кодинга
    noto-fonts-color-emoji     # цветные эмодзи
  ];

  # ==========================================
  # Оптимизация под SSD и энергосбережение Intel
  # ==========================================
  # Тримминг SSD раз в неделю для сохранения скорости и ресурса
  services.fstrim.enable = true;

  # Контроль нагрева процессоров Intel (критично для ультрабуков)
  services.thermald.enable = true;

  # Плавное масштабирование частоты процессора (без резкого воя кулеров на кликах)
  powerManagement.cpuFreqGovernor = "powersave";

  # Интеграция переключения профилей питания в меню GNOME (Тихий / Баланс / Производительный)
  services.power-profiles-daemon.enable = true;

  # Отключение сна, гибернации и suspend
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  # ==========================================
  # Оптимизация ОЗУ (8 ГБ): ZRAM + Защита от зависаний
  # ==========================================
  # zramSwap сжимает память на лету (алгоритм zstd).
  # 8 ГБ превращаются фактически в ~12-14 ГБ без свопа на диск!
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # использовать до 4 ГБ под сжатый своп
  };

  # Защита от намертво зависшей системы при переполнении памяти
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # убивать самый прожорливый процесс при остатке < 5% RAM
    enableNotifications = true;
  };

  # Ограничение аппетита Nix при сборках (чтобы не вешать 2 ядра и 8GB RAM)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 2;
    cores = 2;
  };

  # ==========================================
  # Драйверы видеокарты (NVIDIA MX110 - архитектура Maxwell)
  # ==========================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # ВНИМАНИЕ: Для MX110 (чип GM108, Maxwell) открытые модули НЕ поддерживаются!
    open = false;

    # finegrained power management поддерживается только начиная с Turing (RTX 20xx / GTX 16xx).
    # Для MX110 оставляем стандартный powerManagement:
    powerManagement.enable = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # NVIDIA PRIME Offload:
    # Дискретная MX110 спит, а система и GNOME работают на экономичной Intel HD 620
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # запускать тяжелый софт командой: nvidia-offload <программа>
      };

      # Для i3-7020U (Intel Kaby Lake):
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Автоматическое переключение видеокарт в GNOME (для 3D и игр)
  services.switcheroo-control.enable = true;

  # ==========================================
  # nix-ld: Декларативный запуск любых Linux бинарников (Happ, AppImage, скрипты)
  # ==========================================
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    glib
    gtk3
    nss
    nspr
    alsa-lib
    libdrm
    mesa
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  # ==========================================
  # Разрешение несвободных пакетов и очистка
  # ==========================================
  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ==========================================
  # Пользователь
  # ==========================================
  # Пароль задается безопасно при установке системы через инсталлятор.
  users.users.mestorixx = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "adbusers" ];
  };

  # ==========================================
  # Android Debug Bridge (ADB) + udev правила для смартфонов
  # ==========================================
  programs.adb.enable = true;

  # ==========================================
  # Игры: Steam + GameMode
  # ==========================================
  programs.steam = {
    enable = true;
    # Входящие порты закрыты для безопасности в публичных сетях Wi-Fi:
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    extraPackages = with pkgs; [ tetrio-desktop ]; # TETR.IO через Steam окружение
  };
  programs.gamemode.enable = true;

  # ==========================================
  # Оптимизация GNOME (отключение прожорливых фоновых индексаторов)
  # ==========================================
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  # ==========================================
  # Tailscale — личный VPN / mesh-сеть
  # ==========================================
  # После rebuild: sudo tailscale up -> авторизоваться через браузер
  services.tailscale.enable = true;

  # ==========================================
  # ZeroTier — виртуальная LAN для игр и доступа к устройствам
  # ==========================================
  # После rebuild: sudo zerotier-cli join <network-id>
  services.zerotierone.enable = true;

  # ==========================================
  # OpenTabletDriver — драйвер графического планшета
  # ==========================================
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # ==========================================
  # Zapret — обход блокировок DPI (Роскомнадзор)
  # ==========================================
  # Работает прозрачно в фоне, не требует VPN для обычных сайтов.
  # ВАЖНО: параметры подбираются под провайдера.
  # Актуальные параметры: https://t.me/zapret_discuss или https://t.me/antizapret
  environment.etc."zapret/params".text = ''
    --dpi-desync=fake,split2
    --dpi-desync-ttl=5
    --dpi-desync-fooling=md5sig
    --filter-tcp=80,443
    --filter-udp=443
  '';

  systemd.services.zapret = {
    description = "Zapret DPI bypass service";
    after = [ "network.target" "nftables.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        # Перенаправить трафик в nfqueue
        "${pkgs.nftables}/bin/nft add table inet zapret"
        "${pkgs.nftables}/bin/nft add chain inet zapret output { type filter hook output priority -1\\; }"
        "${pkgs.nftables}/bin/nft add rule inet zapret output tcp dport { 80, 443 } ct state new,established queue num 200 bypass"
        "${pkgs.nftables}/bin/nft add rule inet zapret output udp dport 443 ct state new,established queue num 200 bypass"
      ];
      ExecStart = "${pkgs.zapret}/bin/nfqws --qnum=200 --dpi-desync=fake,split2 --dpi-desync-ttl=5 --dpi-desync-fooling=md5sig --filter-tcp=80,443 --filter-udp=443";
      ExecStopPost = "${pkgs.nftables}/bin/nft delete table inet zapret";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Модули ядра для zapret (nfqueue)
  boot.kernelModules = [ "nf_conntrack" "xt_NFQUEUE" ];

  # ==========================================
  # Системные пакеты и приложения
  # ==========================================
  environment.systemPackages = with pkgs; [
    # Сеть / VPN
    v2raya         # VLESS/Reality VPN (web GUI на localhost:2017, запуск: sudo systemctl start v2raya)

    # Браузер и интернет
    firefox
    thunderbird      # почтовый клиент (Gmail и др.)
    telegram-desktop
    qbittorrent
    obsidian
    element-desktop  # Matrix / Element мессенджер
    gnome-pomodoro  # таймер помодоро, встраивается в панель GNOME

    # Медиа и графика
    spotify
    feishin          # плеер для Navidrome / Subsonic (современный GUI)
    vlc              # всеядный видеоплеер
    obs-studio
    audacity
    libreoffice
    krita            # растровый графический редактор (для планшета)

    # Разработка и инструменты
    vscode
    (python3.withPackages (ps: with ps; [
      pip
      virtualenv
    ]))
    git
    gh
    curl
    wget
    pciutils
    htop
    fastfetch
    unzip
    p7zip
    woeusb-ng      # запись Windows ISO на флешку (с GUI)
    balena-etcher  # запись любых ISO на флешку (с GUI)
    gnome-tweaks
    gnome-extension-manager  # установка расширений GNOME через GUI
    flameshot                # продвинутые скриншоты со стрелками и текстом (Super+Shift+S)
    gtick                    # метроном для барабанов
  ];

  system.stateVersion = "24.11";
}
