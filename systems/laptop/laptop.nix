# This contains configuration settings for laptop systems.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Microphone workaround
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "resume_offset=32563200"
    # Enable AMD P-state EPP for fine-grained CPU power/performance control
    "amd_pstate=active"
    # Allow PCIe devices to enter low-power link states aggressively
    "pcie_aspm.policy=powersupersave"
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/a4be4019-5beb-4f5f-9d16-341c6bfbdf2f";

  # Flush dirty pages every 15s instead of the default 5s — fewer SSD/CPU wakeups
  boot.kernel.sysctl."vm.dirty_writeback_centisecs" = 1500;

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
  };

  services.hardware.bolt.enable = true;
  services.fprintd.enable = true;

  # When the lid is closed (clamshell/docked) the fingerprint reader is awkward
  # to reach, so skip it and fall back to the password prompt for sudo. The
  # helper exits 0 only when the lid is closed; the control flag then jumps over
  # the pam_fprintd rule (order 11400) straight to pam_unix. With the lid open
  # the helper exits non-zero and is ignored, leaving fingerprint auth intact.
  security.pam.services.sudo.rules.auth.skipFprintdInClamshell = {
    order = 11399;
    control = "[success=1 default=ignore]";
    modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
    args = [
      "quiet"
      (toString (pkgs.writeShellScript "lid-closed" ''
        ${pkgs.ripgrep}/bin/rg -q closed /proc/acpi/button/lid/*/state
      ''))
    ];
  };

  age.secrets.gpg_passphrase = {
    file = ../../secrets/gpg_passphrase.age;
    mode = "400";
    owner = "carl";
    group = "users";
  };

  powerManagement.enable = true;

  # Manages amd_pstate EPP hint: power-saver / balanced / performance.
  # Switch profiles via: powerprofilesctl set power-saver
  services.power-profiles-daemon.enable = true;

  # WiFi power saving — reduces idle draw without noticeable latency impact.
  networking.networkmanager.wifi.powersave = true;

  # PCI runtime PM: adding the rule below to services.udev.extraRules would
  # allow idle PCIe devices (WiFi, NVMe) to enter D3. Small gain (~0.2W) but
  # the MT7925 driver is new enough that it risks intermittent disconnects.
  # Revisit once the mt7925e driver matures.
  #   ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.hostName = "freia";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  # When Tailscale MagicDNS is unreachable (traveling, server down), fall back
  # to public resolvers instead of hanging.
  services.resolved = {
    enable = true;
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  };

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    fwupd
    brightnessctl
    moonlight-qt
    spotify
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.udev.extraHwdb = ''
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc
  '';
}
