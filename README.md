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
    - `desktop/gnome.nix` — GNOME dconf (тема, кнопки окон, хоткеи Flameshot) и декларативные расширения (AppIndicator, Vitals, Dash to Dock);
    - `desktop/apps.nix` — GUI-приложения и Firefox (VA-API аппаратное ускорение, блокировка телеметрии, uBlock Origin);
    - `gaming/minecraft.nix` — PrismLauncher, Legacy Launcher (KLauncher через `pkgs.fetchurl`), OpenJDK (Java 17, 21);
    - `dev/default.nix` — окружение разработки: `direnv` + `nix-direnv`, `starship`, `zoxide`, `eza`, `bat`, `fzf`, `git`, `vscode`.

---

## Управление системой через `nh` (Nix Helper)

Вся сборка и обслуживание теперь происходят через утилиту `nh`:

```bash
# Применить конфигурацию системы (с визуальным диффом nvd)
nh os switch

# Собрать конфигурацию для следующей перезагрузки
nh os boot

# Очистить старые поколения (оставив последние 3 поколения и не старше 4 дней)
nh clean all --keep 3

# Обновить зависимости flake
nix flake update
```

Также доступны алиасы Justfile:
```bash
just switch   # nh os switch
just clean    # nh clean all --keep 3
just check    # nix flake check
```

---

## Dev-окружения с direnv

Вместо глобальной установки библиотек для Python/Node/Rust в каждом проекте используется изолированное окружение:

В корне проекта создайте `.envrc`:
```bash
use flake
```
При входе в каталог с проектом окружение активируется автоматически, а при выходе — выгружается.
