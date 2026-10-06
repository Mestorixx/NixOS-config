{ pkgs, ... }:

let
  # Ulauncher с поддержкой транслитерации раскладок (RU <-> EN)
  # и увеличенным таймаутом потери фокуса для переключения раскладки по Super+Space
  ulauncher-custom = pkgs.ulauncher.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace ulauncher/ui/windows/UlauncherWindow.py \
        --replace-fail "threading.Timer(0.07," "threading.Timer(1.0,"

      cat << 'EOF' >> ulauncher/utils/fuzzy_search.py

_EN = r"""qwertyuiop[]asdfghjkl;'zxcvbnm,./`QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?~"""
_RU = r"""йцукенгшщзхъфывапролджэячсмитьбю.ёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,Ё"""
_RU2EN = str.maketrans(_RU, _EN)
_EN2RU = str.maketrans(_EN, _RU)

def _trans(text):
    t = text.translate(_RU2EN)
    if t != text:
        return t
    return text.translate(_EN2RU)

_raw_get_score = get_score
_raw_get_matching_indexes = get_matching_indexes

def get_matching_indexes(query, text):
    res = _raw_get_matching_indexes(query, text)
    if not res:
        alt = _trans(query)
        if alt != query:
            res = _raw_get_matching_indexes(alt, text)
    return res

def get_score(query, text):
    s = _raw_get_score(query, text)
    alt = _trans(query)
    if alt != query:
        s = max(s, _raw_get_score(alt, text))
    return s
EOF

      substituteInPlace ulauncher/search/apps/AppSearchMode.py \
        --replace-fail "return RenderResultListAction(result_list)" '
        clean_q = query.strip()
        if len(clean_q) >= 2:
            try:
                import subprocess, os, re
                from ulauncher.utils.Path import Path
                from ulauncher.search.file_browser.FileBrowserResultItem import FileBrowserResultItem
                from ulauncher.utils.fuzzy_search import _trans

                alt_q = _trans(clean_q)
                pattern = f"({re.escape(clean_q)}|{re.escape(alt_q)})" if alt_q != clean_q else re.escape(clean_q)
                home = os.path.expanduser("~")
                cmd = ["${pkgs.fd}/bin/fd", "--max-results", "6", pattern, home]
                out = subprocess.check_output(cmd, stderr=subprocess.DEVNULL, timeout=0.25)
                for line in out.decode("utf-8", errors="ignore").splitlines():
                    p = line.strip()
                    if p:
                        result_list.append(FileBrowserResultItem(Path(p)))
            except Exception:
                pass
        return RenderResultListAction(result_list)'
    '';
  });

  catppuccin-gtk-pkg = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    size = "compact";
    variant = "mocha";
  };

  catppuccin-papirus-pkg = pkgs.catppuccin-papirus-folders.override {
    flavor = "mocha";
    accent = "lavender";
  };
in
{
  home.packages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    gnome-pomodoro
    flameshot
    ulauncher-custom

    # Цветовая тема Catppuccin Mocha Lavender
    catppuccin-gtk-pkg
    catppuccin-papirus-pkg
    catppuccin-cursors.mochaLavender

    # Декларативные расширения GNOME
    gnomeExtensions.appindicator
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.tiling-shell
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.user-themes
  ];

  # GTK 2/3 темы и курсоры
  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = "catppuccin-mocha-lavender-compact";
      package = catppuccin-gtk-pkg;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = catppuccin-papirus-pkg;
    };
    cursorTheme = {
      name = "catppuccin-mocha-lavender-cursors";
      package = pkgs.catppuccin-cursors.mochaLavender;
      size = 24;
    };
  };

  # Курсоры для всей системы (включая X11/Wayland)
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-lavender-cursors";
    package = pkgs.catppuccin-cursors.mochaLavender;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Поддержка темы Catppuccin для GTK 4 / Libadwaita приложений (Nautilus, Настройки, Консоль и др.)
  xdg.configFile = {
    "gtk-4.0/assets".source = "${catppuccin-gtk-pkg}/share/themes/catppuccin-mocha-lavender-compact/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${catppuccin-gtk-pkg}/share/themes/catppuccin-mocha-lavender-compact/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${catppuccin-gtk-pkg}/share/themes/catppuccin-mocha-lavender-compact/gtk-4.0/gtk-dark.css";
  };

  # Подключение темы оболочки GNOME для расширения user-themes
  home.file = {
    ".local/share/themes/catppuccin-mocha-lavender-compact".source = "${catppuccin-gtk-pkg}/share/themes/catppuccin-mocha-lavender-compact";
    ".themes/catppuccin-mocha-lavender-compact".source = "${catppuccin-gtk-pkg}/share/themes/catppuccin-mocha-lavender-compact";
  };

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
      gtk-theme = "catppuccin-mocha-lavender-compact";
      icon-theme = "Papirus-Dark";
      cursor-theme = "catppuccin-mocha-lavender-cursors";
      cursor-size = 24;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "Vitals@CoreCoding.com"
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "tilingshell@ferrarodomenico.com"
        "compiz-windows-effect@hermes83.github.com"
        "clipboard-indicator@tudmotu.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "catppuccin-mocha-lavender-compact";
    };

    # Автоочистка корзины и временных файлов старше 30 дней (как в macOS)
    "org/gnome/desktop/privacy" = {
      remove-old-trash-files = true;
      remove-old-temp-files = true;
    };

    # Желейные окна: пресет эффекта
    "org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
      preset = "R";
    };

    # Раскладка запоминается для каждого окна (как на macOS) + переключение Alt+Shift без оверлея
    "org/gnome/desktop/input-sources" = {
      per-window = true;
      xkb-options = [ "grp:alt_shift_toggle" ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dash-max-icon-size = 48;
      custom-theme-shrink = true;
      intellihide = true;
      hot-keys = false;
      apply-custom-theme = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = false;
    };

    # Пользовательские горячие клавиши
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/firefox/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/spotify/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/telegram/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot" = {
      binding = "<Super><Shift>s";
      command = "flameshot gui";
      name = "Flameshot";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/firefox" = {
      binding = "<Super>b";
      command = "firefox";
      name = "Firefox";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/spotify" = {
      binding = "<Super>p";
      command = "spotify";
      name = "Spotify";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/telegram" = {
      binding = "<Super>m";
      command = "Telegram";
      name = "Telegram";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher" = {
      binding = "<Super>t";
      command = "${ulauncher-custom}/bin/ulauncher-toggle";
      name = "Ulauncher";
    };
  };

  # Фоновый запуск Ulauncher при старте графической сессии
  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Ulauncher Application Launcher";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${ulauncher-custom}/bin/ulauncher --hide-window";
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
