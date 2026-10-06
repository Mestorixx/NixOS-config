#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  NixOS Dotfiles Installer
#  Автоматическая установка, перенос hardware-config и умная сборка с учетом CPU/RAM
#  Сделано с любовью Claude и Gemini ❤️
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/etc/nixos"
HOST="chungie-laptop"
HOST_HW="$SCRIPT_DIR/hosts/$HOST/hardware-configuration.nix"

echo "========================================================"
echo "  🚀 NixOS Dotfiles Installer"
echo "  💻 Хост: $HOST"
echo "========================================================"

if [[ $EUID -ne 0 ]]; then
  echo "❌ Ошибка: запусти скрипт через sudo:"
  echo "   sudo ./install.sh"
  exit 1
fi

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo mestorixx)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6 || echo "/home/$REAL_USER")"

echo "👤 Пользователь: $REAL_USER ($REAL_HOME)"

# 1. Железо (hardware-configuration.nix)
echo ""
echo "🔍 Проверка конфигурации железа..."
if [[ -f "/etc/nixos/hardware-configuration.nix" && ! -L "/etc/nixos/hardware-configuration.nix" ]]; then
  echo "📦 Найдена текущая /etc/nixos/hardware-configuration.nix — копируем в хост $HOST..."
  cp "/etc/nixos/hardware-configuration.nix" "$HOST_HW"
elif [[ ! -f "$HOST_HW" || "$(cat "$HOST_HW")" =~ REPLACE_THIS_FILE_WITH_GENERATED ]]; then
  echo "⚙️ Генерируем аппаратную конфигурацию через nixos-generate-config..."
  mkdir -p "$(dirname "$HOST_HW")"
  nixos-generate-config --show-hardware-config > "$HOST_HW"
else
  echo "✅ Аппаратная конфигурация уже присутствует в $HOST_HW"
fi

# 2. Создание симлинков /etc/nixos -> $SCRIPT_DIR
echo ""
echo "🔗 Настройка симлинков /etc/nixos..."
mkdir -p "$TARGET_DIR"
for item in flake.nix flake.lock configuration.nix Justfile hosts home README.md; do
  if [[ -e "$SCRIPT_DIR/$item" ]]; then
    ln -sfn "$SCRIPT_DIR/$item" "$TARGET_DIR/$item"
  fi
done

# 3. Умное определение ядер и RAM
echo ""
echo "🧠 Анализ характеристик процессора и памяти..."
CORES=$(nproc)
RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 8)

echo "📊 Обнаружено: $CORES потоков CPU, ${RAM_GB}ГБ оперативной памяти."

if [ "$CORES" -le 4 ] || [ "$RAM_GB" -le 8 ]; then
  BUILD_CORES=$(( CORES > 1 ? CORES - 1 : 1 ))
  echo "⚡ Внимание: компактная система!"
  echo "👉 Ограничиваем нагрузку: $BUILD_CORES ядер, 1 поток параллелизма."
  echo "   (Это защитит систему от зависаний интерфейса и вылетов по памяти)"
  BUILD_FLAGS="--cores $BUILD_CORES --max-jobs 1"
  NH_BUILD_FLAGS="--cores $BUILD_CORES -j 1"
else
  echo "🚀 Мощная система! Сборка пойдёт на полной скорости на всех ядрах."
  BUILD_FLAGS=""
  NH_BUILD_FLAGS=""
fi

# 4. Проверка flake и первая сборка
echo ""
echo "🔨 Проверка Flake..."
nix flake check "$SCRIPT_DIR"

echo ""
echo "📦 Запуск сборки и активации системы..."
if command -v nh &>/dev/null; then
  echo "⚡ Используем nh os switch..."
  nh os switch "$SCRIPT_DIR" $NH_BUILD_FLAGS
else
  echo "⚙️ nh ещё не установлен, собираем через nixos-rebuild..."
  nixos-rebuild switch --flake "$SCRIPT_DIR#$HOST" $BUILD_FLAGS
fi

echo ""
echo "========================================================"
echo "  🎉 Система успешно собрана и активирована!"
echo "  ❤️  Сделано с любовью Claude и Gemini"
echo "========================================================"
