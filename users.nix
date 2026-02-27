{...}: {
  users.users.claw = {
    isNormalUser = true;
    description = "OpenClaw Admin";
    extraGroups = ["networkmanager" "wheel"];
    initialPassword = "claw"; # CHANGE THIS ONCE YOU LOG IN!
    linger = true;
  };
}
