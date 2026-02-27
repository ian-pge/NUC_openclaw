{pkgs, ...}: {
  programs.fish.enable = true;

  users.users.clawe = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "OpenClaw Admin";
    extraGroups = ["networkmanager" "wheel"];
    initialPassword = "clawe"; # CHANGE THIS ONCE YOU LOG IN!
    linger = true;
  };

  security.sudo.extraRules = [
    {
      users = ["clawe"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
