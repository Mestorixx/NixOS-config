set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Собрать и применить конфигурацию системы через nh
switch:
    nh os switch

# Собрать конфигурацию для следующей загрузки
boot:
    nh os boot

# Очистить старые поколения системы и кэш
clean:
    nh clean all --keep 3

# Обновить flake lock
update:
    nix flake update

# Проверить синтаксис и flake
check:
    nix flake check
