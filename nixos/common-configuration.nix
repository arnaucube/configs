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


  environment.systemPackages = with pkgs; [
	# minimal
  	vim
	neovim
 	wget
	tmux
	git
	delta
	tig
	mosh
	bat
	lf
	ripgrep
	fzf
	screenfetch
	htop
	alacritty
	zathura
	mate.atril
	xclip # to make clipboard work in neovim
	xorg.xmodmap
	xfce.xfce4-screenshooter
	xfce.thunar
	xfce.xfconf # needed to save preferences of thunar
	xfce.ristretto
	xfce.tumbler # for thumbnails of imgs
	pavucontrol
	jq
	keynav

	# other
	mpv
	feh
	kolourpaint

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
	#gcc
	clang
	clang-tools
	pkg-config
	openssl
	stdenv
	rustup
	sage
	go
	python3
	pipx
	nodejs

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

  xdg.mime.enable=true;
  xdg.mime.defaultApplications = {
    "application/pdf" = "zathura";
  };
}
