# sway config at ~/.config/sway/config calls this script, through line:
#     status_command while ~/.config/sway/status.sh; do sleep 1; done
# Changes should be applied when saving this script, if not, use
# "killall swaybar" and $mod+Shift+c to reload the configuration.

uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)

# date and time format: Tue 2025-08-19 22:37
date_formatted=$(date "+%a %F %H:%M")

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
# if [ "$MUTED" = "yes" ]; then // TODO
#     echo "🔇 Muted"
# else
#     echo "🔊 $VOLUME"
# fi

battery_status=$(cat /sys/class/power_supply/BAT0/status) # "Full", "Discharging", or "Charging"
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity) # %

# 💎 💻 💡 🔌 ⚡ 📁 \| 🐧
echo $uptime_formatted ↑ $volume $muted 🔊 $battery_status $battery_capacity% 🔋 $date_formatted
