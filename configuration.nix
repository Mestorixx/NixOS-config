# Совместимость: позволяет делать nixos-rebuild из /etc/nixos без --flake.
# Настоящее описание машины — в hosts/chungie-laptop.
{ ... }:
{
  imports = [
    ./hosts/chungie-laptop
  ];
}
