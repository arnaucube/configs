# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./surface-extra-hardware-configuration.nix
      ./private-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";

    enable=true;
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable=true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.userc = {
    isNormalUser = true;
    description = "userc";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	vim
	neovim
 	wget
	tmux
	git
	delta
	tig
	mosh
	bat
	ripgrep
	fzf
	python3
	xfce.thunar
	xfce.xfconf # needed to save preferences of thunar
	screenfetch
	htop
	alacritty
	zathura
	mate.atril
	firefox
	qutebrowser
	chromium
	xfce.ristretto
	pavucontrol
	texlive.combined.scheme-medium # includes latexmk
	#pgf-umlsd # latex diagrams
	#pgf
	(pkgs.texlive.combine {
		inherit (pkgs.texlive)
		scheme-medium
		pgf
		;
	})
	sage
	rustup
	gcc
	go
	nodejs
	xclip # to make clipboard work in neovim
	xfce.xfce4-screenshooter
	mpv
	xorg.xmodmap
	feh
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # gvfs needed for Thunar to detect external disks
  services.gvfs.enable = true;

  # bluetooth related
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # obs virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
}
