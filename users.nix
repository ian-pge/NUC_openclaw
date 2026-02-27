{...}: {
  users.users.clawe = {
    isNormalUser = true;
    description = "OpenClaw Admin";
    extraGroups = ["networkmanager" "wheel"];
    initialPassword = "clawe"; # CHANGE THIS ONCE YOU LOG IN!
    linger = true;
  };
}
