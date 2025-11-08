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
    LC_TIME = "en_US.UTF-8";
  };

#  services.displayManager = {
#      defaultSession = "none+i3";
#  };
  services.xserver = {
    xkb = { # Configure keymap in X11
      layout = "us";
      variant = "";
    };

    enable=true;
#    #displayManager = {
#    #  defaultSession = "none+i3";
#    #};
#    windowManager.i3 = {
#      enable=true;
#      extraPackages = with pkgs; [
#        dmenu
#        i3status
#        i3lock
#      ];
#    };
  };
  # --- sway wm config:
  services.xserver.displayManager.gdm.enable=true;
  #services.displayManager.sessionPackages = [ pkgs.sway ];
  #services.xserver.displayManager.gdm.wayland=false;
  #services.xserver.displayManager.plasma5.enable=true;
  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
  # enable sway wm
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  security.polkit.enable = true;
  # --- end of sway config.

  environment.systemPackages = with pkgs; [
	# sway wm utilities
	grim # screenshot functionality
	slurp # screenshot functionality
	wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
	mako # notification system developed by swaywm maintainer

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
	time
	#impala # nmtui alternative
	fastfetch
	rpm
	pdfgrep # to find strings across pdfs in directories

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
	#kolourpaint
	gimp
	calibre
	tauon
	libsForQt5.kdenlive
	libreoffice-qt6
	ffmpeg

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
	gcc
	clang
	clang-tools

	openssl
	openssl.dev
	glib       # GLib base library
	#gio        # GIO library
	gdk-pixbuf # GDK Pixbuf library
	gtk3       # GTK3 including GDK, relevant for gdk-sys
	atk        # Accessibility Toolkit
	cairo      # 2D graphics library
	pango      # Text layout and rendering
	pkg-config # Needed for pkg-config to find .pc files
	cmake

	stdenv
	rustup
	wabt # wasm binary toolkit
	wasmedge # to execute wasm binaries
	sage
	coq
	coqPackages.mathcomp
	#coqPackages.coqide
	opam # ocaml package manager, for coq packages
	go
	(python3.withPackages(ps: with ps; [
		matplotlib numpy
		qmk
		meshtastic esptool # meshtastic related
		unicodeit
		setuptools
	]))
	pipx
	nodejs
	pnpm

	# other
	qmk
	vial
	via

	freecad
	orca-slicer
  ];

  environment.variables = {
	OPENSSL_DEV = "${pkgs.openssl.dev}";
	OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
	OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
	PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

	OPENSSL_NO_VENDOR="1";
	OPENSSL_STATIC="0";

	# for screen sharing in sway
	XDG_CURRENT_DESKTOP = "sway";
	XDG_SESSION_TYPE="wayland";

	WAYLAND_DISPLAY="wayland-1";
	XDG_RUNTIME_DIR="/run/user/$(id -u)";
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
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
  };

  # gvfs needed for Thunar to detect external disks
  services.gvfs.enable = true;

  hardware.graphics.enable = true;

  # bluetooth related
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  #hardware.pulseaudio.enable = true;
  #services.pulseaudio.enable = true;
  #services.pipewire.pulse.enable=false;
  #services.pipewire.enable=false;
  services.pipewire = {
    enable = true;          # Enable PipeWire service
    alsa.enable = true;     # Enable ALSA support (audio hardware)
    alsa.support32Bit = true; # Support 32-bit apps on 64-bit systems
    pulse.enable = true;    # Enable PipeWire PulseAudio replacement
    wireplumber.enable = true; # Enable WirePlumber session manager (recommended)
    jack.enable = true;     # Enable JACK support if needed
  };

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

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];
}
