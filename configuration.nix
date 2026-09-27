# Совместимость: позволяет делать nixos-rebuild из /etc/nixos без --flake.
# Настоящее описание машины — в hosts/chungie-laptop.
{ ... }:
{
  imports = [
    ./hosts/chungie-laptop
  ];
networking.nameservers = [ "45.155.204.190" "95.182.120.241" ];

}
