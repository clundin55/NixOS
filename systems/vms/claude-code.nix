{ pkgs, carlKeys, ... }: {
  microvm.hypervisor = "cloud-hypervisor";
  microvm.mem = 16384;
  microvm.vcpu = 8;

  microvm.shares = [{
    tag = "code";
    source = "/home/carl/code";
    mountPoint = "/home/carl/code";
    proto = "virtiofs";
  }];

  microvm.interfaces = [{
    type = "tap";
    id = "vm-claude";
    mac = "02:00:00:00:00:01";
  }];

  # Match by MAC so interface name doesn't matter
  networking.useNetworkd = true;
  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = "02:00:00:00:00:01";
    networkConfig = {
      Address = "10.0.100.2/24";
      Gateway = "10.0.100.1";
      DNS = "1.1.1.1";
    };
  };

  networking.hostName = "claude-code";

  users.users.carl = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = carlKeys;
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    claude-code
    curl
    vim
  ];

  system.stateVersion = "26.05";
}
