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
