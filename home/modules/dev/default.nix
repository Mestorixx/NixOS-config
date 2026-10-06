{ pkgs, ... }:

{
  # Контроль версий
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mestorixx";
        email = "mestorixx@chungie-laptop";
      };
      credential.helper = "!gh auth git-credential";
    };
  };

  # Оболочка Bash и алиасы для удобства
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      cat = "bat";
      rebuild = "nh os switch";
    };
  };

  # Быстрый и информативный шелл-промпт
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };

  # Умная навигация по каталогам (z instead of cd)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # Современная замена ls с подсветкой и иконками
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    icons = "auto";
    git = true;
  };

  # Современная замена cat с подсветкой синтаксиса
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  # Интерактивный нечеткий поиск по истории и файлам (Ctrl+R, Ctrl+T)
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget.command = "fd --type f --hidden --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
  };

  # Изолированные dev-окружения для проектов (direnv + nix-direnv)
  # Позволяет не захламлять систему глобальными пакетами
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Быстрый GPU-терминал с аппаратным ускорением и богатыми возможностями
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11.5;
    };

    settings = {
      # Оптимизация задержки и энергопотребления (Intel HD 620)
      repaint_delay = 10;
      input_delay = 2;
      sync_to_monitor = "yes";
      wayland_enable_ime = "no";

      # Визуальный комфорт и отступы
      window_padding_width = 12;
      placement_strategy = "center";
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;

      # Курсор
      cursor_shape = "beam";
      cursor_blink_interval = 0;

      # Прокрутка и буфер
      scrollback_lines = 10000;
      wheel_scroll_multiplier = "3.0";
      touch_scroll_multiplier = "3.0";

      # Звуки
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";

      # Вкладки и сплиты
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_font_style = "bold";

      # Ссылки и мышь
      url_style = "curly";
      open_url_with = "default";
      detect_urls = "yes";
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      mouse_hide_wait = "3.0";
    };

    keybindings = {
      # Сплиты (разбиение окна)
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+]" = "next_window";

      # Вкладки
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";

      # Изменение размера шрифта
      "ctrl+equal" = "change_font_size all +1.0";
      "ctrl+minus" = "change_font_size all -1.0";
      "ctrl+0" = "change_font_size all 0";
    };
  };

  home.packages = with pkgs; [
    vscode
    vscode-extensions.catppuccin.catppuccin-vsc
    python3
    antigravity-cli
    fd
    ripgrep
    just
  ];
}
