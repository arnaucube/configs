# This is a custom file for a surface.

{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
	obs-studio
	rnote
	xournalpp
  ];


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

  # prevent suspend on folding
  services.logind.lidSwitch = "ignore";

  # next sleep & wake is code from: https://github.com/hpfr/system/blob/2e5b3b967b0436203d7add6adbd6b6f55e87cf3c/hosts/linux-surface.nix
  # systemd.services = {
  #   surface-sleep = {
  #     enable = lib.versionOlder config.boot.kernelPackages.kernel.version "5.4";
  #     before = [ "suspend.target" ];
  #     wantedBy = [ "suspend.target" ];
  #     serviceConfig.Type = "oneshot";
  #     path = with pkgs; [ procps kmod bluez ];
  #     script = ''
  #       # Disable bluetooth if no device is connected
  #       if ps cax | grep bluetoothd && ! bluetoothctl info; then
  #         bluetoothctl power off
  #       fi

  #       ## Disable bluetooth regardless if devices are connected (see notes below)
  #       # if ps cax | grep bluetoothd; then
  #       #   bluetoothctl power off
  #       # fi

  #       ## > Remove IPTS from ME side
  #       modprobe -r ipts_surface
  #       modprobe -r intel_ipts
  #       # modprobe -r mei_hdcp
  #       modprobe -r mei_me
  #       modprobe -r mei
  #       ## > Remove IPTS from i915 side
  #       for i in $(find /sys/kernel/debug/dri -name i915_ipts_cleanup); do
  #         echo 1 > $i
  #       done
  #     '';
  #   };
  #   surface-wake = {
  #     enable = lib.versionOlder config.boot.kernelPackages.kernel.version "5.4";
  #     after = [ "post-resume.target" ];
  #     wantedBy = [ "post-resume.target" ];
  #     serviceConfig.Type = "oneshot";
  #     path = with pkgs; [ procps kmod bluez ];
  #     script = ''
  #       ## > Load IPTS from i915 side
  #       for i in $(find /sys/kernel/debug/dri -name i915_ipts_init); do
  #         echo 1 > $i
  #       done
  #       ## > Load IPTS from ME side
  #       modprobe mei
  #       modprobe mei_me
  #       # modprobe mei_hdcp
  #       modprobe intel_ipts
  #       modprobe ipts_surface

  #       # Restart bluetooth
  #       if ps cax | grep bluetoothd; then
  #         bluetoothctl power on
  #       fi
  #     '';
  #   };
  # };

## NOTES:
# Susspend issue:
# https://github.com/linux-surface/linux-surface/wiki/Known-Issues-and-FAQ#suspend-aka-sleep-vs-lid-closingopening-events
# run:
# > sudo modprobe -r surface_gpe
# and:
# > sudo bash -c 'echo -e "\n# Blacklisting lid vs. suspend issue module\nblacklist surface_gpe" >> /etc/modprobe.d/blacklist.conf'
#
# Now folding the keyboard to the screen will not suspend and brick the
# session, but you will need to manually suspend the session if saving battery
# is desired.
}
