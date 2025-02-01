# This file contains the config shared across different devices.

{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  services.displayManager = {
      defaultSession = "none+i3";
  };
  services.xserver = {
    xkb = { # Configure keymap in X11
      layout = "us";
      variant = "";
    };

    enable=true;
    #displayManager = {
    #  defaultSession = "none+i3";
    #};
    windowManager.i3 = {
      enable=true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };

  environment.systemPackages = with pkgs; [
	# utilities
 	wget
	tmux
	git
	delta
	tig
	mosh
	bat
	ripgrep
	fzf
	screenfetch
	htop
	jq
	keynav
	unzip
	gnutar
	xorg.xmodmap # keyboard remapping
	xfce.xfce4-screenshooter
	pulseaudio
	usbutils

	# code editors
  	vim
	neovim
	vimHugeX # to make clipboard work in vim
	xclip # to make clipboard work in neovim

	# terminals
	alacritty
	kitty

	# pdf
	zathura
	mate.atril

	# file explorers/managers
	lf
	yazi
	xfce.thunar
	xfce.xfconf # needed to save preferences of thunar
	xfce.ristretto
	xfce.tumbler # for thumbnails of imgs
	# for detecting usbs:
	xfce.thunar-volman
	gvfs
	polkit_gnome
	udiskie

	# media
	pavucontrol
	mpv
	vlc
	feh
	kolourpaint
	calibre

	# browsers
	firefox
	qutebrowser
	chromium

	# languages
	#texlive.combined.scheme-medium # includes latexmk
	#texlivePackages.minted
	pgf-umlsd # latex diagrams
	pgf
	(pkgs.texlive.combine {
		inherit (pkgs.texlive)
		scheme-medium # includes latexmk
		minted # syntax highligting
		pgf
		;
	})
	gnumake
	#gcc
	clang
	clang-tools
	pkg-config
	openssl.dev
	stdenv
	rustup
	wabt # wasm binary toolkit
	wasmedge # to execute wasm binaries
	sage
	go
	(python3.withPackages(ps: with ps; [
		matplotlib numpy qmk
	]))
	pipx
	nodejs

	# other
	qmk
	vial
	via
  ];

  environment.variables = {
 	LIBCLANG_PATH = "${pkgs.llvmPackages_17.libclang.lib}/lib";
	PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
	OPENSSL_DIR = "${pkgs.openssl.dev}";
  };

  fonts.packages = with pkgs; [
    dina-font
    proggyfonts
    terminus_font
    fira-code
    liberation_ttf
    noto-fonts
    tamsyn
    termsyn
    gohufont
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  # set default pdf reader to zathura
  xdg.mime.enable=true;
  environment.sessionVariables = {
    BROWSER = "zathura";
  };
  xdg.mime.defaultApplications = {
    "application/pdf" = "zathura";
  };

  # gvfs needed for Thunar to detect external disks
  services.gvfs.enable = true;

  # bluetooth related
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #hardware.pulseaudio.enable = true;

  # udev rules (for Vial)
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="4653", ATTRS{idProduct}=="0001", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
  services.udev.packages = with pkgs; [
    qmk
    qmk-udev-rules
    qmk_hid
    via
    vial
  ];
}
