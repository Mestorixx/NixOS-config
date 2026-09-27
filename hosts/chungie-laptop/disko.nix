# СПРАВКА. При GUI-установке НЕ используется и никуда не импортируется.
# Оставлен как пример разметки, если когда-нибудь будешь ставить через disko с ISO.
# НЕ запускай disko вслепую — он сотрёт диск.
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/REPLACE_WITH_REAL_SSD_ID";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
