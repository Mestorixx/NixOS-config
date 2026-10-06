set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Умная сборка и применение конфигурации (авто-определение ядер и RAM)
switch *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    CORES=$(nproc)
    RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
    if [ "$CORES" -le 4 ] || [ "$RAM_GB" -le 8 ]; then
        BUILD_CORES=$(( CORES > 1 ? CORES - 1 : 1 ))
        echo "⚡ Обнаружена компактная система: $CORES потоков, ${RAM_GB}ГБ RAM."
        echo "👉 Лимит сборки: $BUILD_CORES ядер, 1 поток (интерфейс не зависнет)."
        nh os switch --cores "$BUILD_CORES" -j 1 {{ARGS}}
    else
        echo "🚀 Мощная система: $CORES потоков, ${RAM_GB}ГБ RAM! Сборка на полной мощности."
        nh os switch {{ARGS}}
    fi

# Сборка для следующей загрузки с авто-определением ядер и RAM
boot *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    CORES=$(nproc)
    RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
    if [ "$CORES" -le 4 ] || [ "$RAM_GB" -le 8 ]; then
        BUILD_CORES=$(( CORES > 1 ? CORES - 1 : 1 ))
        echo "⚡ Обнаружена компактная система: $CORES потоков, ${RAM_GB}ГБ RAM."
        echo "👉 Лимит сборки: $BUILD_CORES ядер, 1 поток (интерфейс не зависнет)."
        nh os boot --cores "$BUILD_CORES" -j 1 {{ARGS}}
    else
        echo "🚀 Мощная система: $CORES потоков, ${RAM_GB}ГБ RAM! Сборка boot на полной мощности."
        nh os boot {{ARGS}}
    fi

# Очистить старые поколения системы и кэш
clean:
    nh clean all --keep 3

# Обновить flake lock
update:
    nix flake update

# Проверить синтаксис и flake
check:
    nix flake check
