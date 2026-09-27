{ pkgs, ... }:

{
  # Контроль версий
  programs.git = {
    enable = true;
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
  };

  # Интерактивный нечеткий поиск по истории и файлам (Ctrl+R, Ctrl+T)
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Изолированные dev-окружения для проектов (direnv + nix-direnv)
  # Позволяет не захламлять систему глобальными пакетами
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    vscode
    python3
    antigravity-cli
  ];
}
