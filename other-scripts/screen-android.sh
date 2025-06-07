xrandr --newmode "1280x720_60.00" 74.48  1280 1336 1472 1664  720 721 724 746  -HSync +Vsync
xrandr --addmode HDMI-1 1280x720_60.00
xrandr --output HDMI-1 --mode 1280x720_60.00 --right-of eDP-1
x11vnc -clip 1280x720+1920+0

# gtf 1920 1080 60

# xrandr --newmode "1920x1080_60.00" 10.73  1920 1656 1784 1648  1080 1081 1084 1085  -HSync +Vsync
# xrandr --addmode HDMI-1 1920x1080_60.00
# xrandr --output HDMI-1 --mode 1920x1080_60.00 --right-of eDP-1
# x11vnc -clip 1920x1080+1920+0
