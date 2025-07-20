# This file is meant to be renamed to `configuration.nix`
# Thinkpad NixOS configuration

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

  networking.hostName = "thinkpad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Define a user account
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
  system.stateVersion = "24.05"; # Did you read the comment?

  # gvfs needed for Thunar to detect external disks
  services.gvfs.enable = true;

  #hardware.pulseaudio.enable = true;

  # allow AppImage programs
  programs.appimage.binfmt = true;
}
