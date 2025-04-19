# This file is meant to be renamed to `configuration.nix`
# Chuwi minibook NixOS configuration

{ config, pkgs, ... }:

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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  hardware.cpu.intel.updateMicrocode = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
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

  # Chuwi specific:
  # fix wifi issues
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # fix screen rotation issue
  boot.kernelParams = [
    "fbcon=rotate:1"
  ];
  services.xserver.xrandrHeads = [
    {
      monitorConfig = "Option \"Rotate\" \"right\"";
      output = "DSI-1";
    }
  ];

  # some extra packages
  environment.systemPackages = with pkgs; [
	# note taking
	rnote
	xournalpp
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
}
