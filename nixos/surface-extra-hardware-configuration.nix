# This is a custom file for a surface.

{ config, lib, pkgs, modulesPath, ... }:

{
  # Set an usable key configuration: Ctrl at capslock, Win at Alt, Alt at Ctrl
  services.xserver.displayManager.sessionCommands =''
    ${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText  "xkb-layout" ''
      !
      ! Swap Caps_Lock and Control_L
      !
      
	remove Lock = Caps_Lock
	remove Control = Control_L
	! keysym Control_L = Caps_Lock
	keysym Control_L = Mode_switch
	keysym Caps_Lock = Control_L
	add Lock = Caps_Lock
	add Control = Control_L

	! map arrows to more ergonomic position
	keycode  43 = h H Left
	keycode  44 = j J Down
	keycode  45 = k K Up 
	keycode  46 = l L Right 
    ''}"
  '';


  # add pulseaudio support to manage audio
  hardware.pulseaudio.enable = true;
}
