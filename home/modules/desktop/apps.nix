{ pkgs, ... }:

{
  # Тюнинг Firefox под слабый процессор и приватность
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        # Аппаратное ускорение видео через VA-API (разгрузка слабого CPU при просмотре видео)
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;
        "widget.dmabuf.wayland-drm-backend.enabled" = true;

        # Блокировка телеметрии и фоновых опросов
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "experiments.supported" = false;
        "experiments.enabled" = false;
        "experiments.manifest.uri" = "";
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "app.shield.optoutstudy.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;

        # Отключение Pocket
        "extensions.pocket.enabled" = false;
      };
    };
  };

  home.packages = with pkgs; [
    thunderbird
    telegram-desktop
    qbittorrent
    obsidian
    element-desktop

    feishin
    spotify
    vlc
    audacity
    obs-studio

    libreoffice
    krita
    opentabletdriver
    woeusb-ng
  ];
}
