{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda"; # <-- CHANGE TO /dev/nvme0n1 IF USING AN NVME DRIVE
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
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
  };
}
