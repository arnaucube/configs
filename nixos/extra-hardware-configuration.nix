# This is a custom file for a chromebook.

{ config, lib, pkgs, modulesPath, ... }:

{
  services.logind.extraConfig = ''
    # disable power button. This is for the chromebook
    HandlePowerKey=ignore
  '';

  # Set an usable key configuration: Ctrl at capslock, Win at Alt, Alt at Ctrl
  services.xserver.displayManager.sessionCommands =''
    ${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText  "xkb-layout" ''
      !
      ! Swap Caps_Lock and Control_L
      !
      
      remove control = Control_L
      remove mod1 = Alt_L
      remove mod4 = Super_L
      
      keysym Control_L = Alt_L
      keysym Super_L = Control_L
      keysym Alt_L = Super_L
      
      add control = Control_L
      add mod1 = Alt_L
      add mod4 = Super_L
    ''}"
  '';
}
