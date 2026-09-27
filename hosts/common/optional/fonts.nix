{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];
}
