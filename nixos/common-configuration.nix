# This file contains the config shared across different devices.

{ pkgs, ... }:

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

  # Sway session managed by greetd.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };

  # Enable and unlock the GNOME Keyring through greetd's PAM session.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  security.polkit.enable = true;

  # Minimal Sway sessions do not process XDG autostart entries, so start the
  # authentication agent explicitly with the graphical user session.
  systemd.user.services.polkit-gnome-authentication-agent = {
    description = "Polkit GNOME authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target"];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  # Automatically mount removable media while the graphical session is active.
  systemd.user.services.udiskie = {
    description = "Udiskie removable media automounter";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.udiskie}/bin/udiskie --no-tray";
      Restart = "on-failure";
    };
  };
  environment.systemPackages = with pkgs; [
    # Sway utilities
    grim
    slurp
    wl-clipboard
    mako

    # Utilities
    wget
    tmux
    git
    delta
    tig
    mosh
    bat
    ripgrep
    fzf
    htop
    jq
    unzip
    gnutar
    flameshot
    pulseaudio
    usbutils
    time
    fastfetch
    rpm
    pdfgrep
    keynav
    screenfetch

    # Editors and terminals
    neovim
    vim-full
    alacritty
    kitty

    # Documents and file management
    zathura
    atril
    lf
    yazi
    thunar
    xfconf
    ristretto
    tumbler
    thunar-volman
    udiskie # auto-mount usb (needed for sway)
    polkit_gnome # let unprivileged users mount filesystems

    # Media
    pavucontrol
    mpv
    vlc
    feh
    gimp
    calibre
    tauon
    kdePackages.kdenlive
    libreoffice-qt6
    ffmpeg

    # Browsers
    firefox
    qutebrowser
    chromium

    # Development
    texlive.combined.scheme-full
    gnumake
    gcc
    clang
    clang-tools
    openssl
    openssl.dev
    glib
    gdk-pixbuf
    gtk3
    atk
    cairo
    pango
    pkg-config
    cmake
    rustup
    wabt
    wasmedge
    sage
    coq
    coqPackages.mathcomp
    opam
    go
    gopls
    (python3.withPackages (ps: with ps; [
      pynvim
      matplotlib
      numpy
      meshtastic
      esptool
      unicodeit
      setuptools
      jupyterlab
    ]))
    nodejs
    pnpm
    elan

    # Keyboard firmware
    qmk
    vial
    via
  ];
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
  environment.shells = [ pkgs.zsh ];

  # Set the web browser and default PDF reader.
  xdg.mime.enable = true;
  environment.sessionVariables = {
    BROWSER = "firefox";
  };
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    config.sway = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
    };
  };

  # gvfs needed for Thunar to detect external disks
  services.gvfs.enable = true;

  hardware.graphics.enable = true;

  # bluetooth related
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  # udev rules (for Vial)
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="4653", ATTRS{idProduct}=="0001", MODE="0660", GROUP="users", TAG+="uaccess"
  '';
  services.udev.packages = [ pkgs.qmk-udev-rules ];

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];
}
