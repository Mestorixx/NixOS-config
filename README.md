# Dotfiles — chungie-laptop

Декларативная конфигурация NixOS и Home-Manager для ноутбука `chungie-laptop`.

## Структура репозитория

- `flake.nix` — точка входа (Flake inputs: nixpkgs-unstable + home-manager).
- `hosts/`
  - `common/global/` — системная база: локаль, GNOME, bluetooth, таймзона, `nh` хелпер.
  - `common/optional/` — модули по требованию:
    - `nix-ld.nix` — единый набор библиотек для запуска неупакованных бинарников;
    - `pipewire.nix` — звук;
    - `fonts.nix` — шрифты;
    - `hardware-nvidia-prime.nix` — гибридная графика Intel/NVIDIA;
    - `zapret.nix` — обход блокировок.
  - `chungie-laptop/` — специфичная конфигурация хоста (LTS-ядро, ZRAM, EarlyOOM, Intel HD 620 VA-API, v2rayA, Steam).
- `home/`
  - `hosts/chungie-laptop.nix` — профиль пользователя `mestorixx`, объединяющий модули.
  - `modules/`
    - `desktop/gnome.nix` — GNOME dconf (тема, кнопки окон, хоткеи Flameshot, Alt+Shift), расширения и кастомный пропатченный Ulauncher (транслитерация RU/EN, мгновенный поиск файлов через `fd`);
    - `desktop/apps.nix` — GUI-приложения и Firefox (VA-API аппаратное ускорение, блокировка телеметрии, uBlock Origin);
    - `gaming/minecraft.nix` — PrismLauncher, Legacy Launcher (KLauncher через `pkgs.fetchurl`), OpenJDK (Java 17, 21);
    - `dev/default.nix` — окружение разработки: `direnv` + `nix-direnv`, `starship`, `zoxide`, `eza`, `bat`, `fzf`, `git`, `vscode`, `just`.

---

## Быстрая установка (Quick Start)

Скрипт автоматически подхватывает конфигурацию железа (`hardware-configuration.nix`), настраивает симлинки в `/etc/nixos` и выполняет **умную адаптивную сборку**:

```bash
git clone https://github.com/mestorixx/dotfiles.git
cd dotfiles
sudo ./install.sh
```

> **Умная сборка:** скрипт анализирует количество потоков процессора (`nproc`) и объем RAM. На компактных/слабых система ($\le 4$ ядер / $\le 8$ ГБ RAM) сборка автоматически ограничивается (`--cores 3 -j 1`), чтобы рабочий стол не зависал, а музыка и браузер оставались плавными. На мощных многоядерных машинах включается максимальная скорость.

---

## Управление системой через `Just` и `nh`

Все повседневные задачи автоматизированы через `Justfile` с адаптивным контролем нагрузки:

```bash
just switch   # Умная сборка и переключение (авто-определение ядер и RAM)
just boot     # Собрать конфигурацию для следующей перезагрузки
just clean    # Очистить старые поколения (оставив последние 3)
just update   # Обновить зависимости flake.lock
just check    # Проверить синтаксис конфигурации
```

---

## Dev-окружения с direnv

Вместо глобальной установки библиотек для Python/Node/Rust в каждом проекте используется изолированное окружение:

В корне проекта создайте `.envrc`:
```bash
use flake
```
При входе в каталог с проектом окружение активируется автоматически, а при выходе — выгружается.

---

> Сделано с любовью Claude и Gemini ❤️

