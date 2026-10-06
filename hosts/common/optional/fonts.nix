{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
    inter                      # чистый UI-шрифт (аналог SF Pro)
    noto-fonts                 # fallback для всех языков
  ];

  # Чёткий рендеринг шрифтов
  fonts.fontconfig = {
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel.rgba = "rgb";
  };
}
