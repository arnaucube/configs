# This file is meant to be renamed to `configuration.nix`
# Chuwi minibook NixOS configuration.

{ pkgs, ... }:

{
  imports =
    [
      ./common-configuration.nix
      ./hardware-configuration.nix
      ./private-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chuwi"; # Define your hostname.
  # NetworkManager owns DHCP for the physical interfaces.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  hardware.cpu.intel.updateMicrocode = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" "incus" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # Chuwi-specific Wi-Fi workaround.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Rotate both the virtual console and the internal Sway output.
  boot.kernelParams = [ "fbcon=rotate:1" ];
  environment.etc."sway/config.d/20-chuwi-display.conf".text = ''
    output DSI-1 transform 90
  '';

  # Chuwi-specific packages.
  environment.systemPackages = with pkgs; [
    rnote
    xournalpp
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  };
}
