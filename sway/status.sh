# sway config at ~/.config/sway/config calls this script, through line:
#     status_command while ~/.config/sway/status.sh; do sleep 1; done
# Changes should be applied when saving this script, if not, use
# "killall swaybar" and $mod+Shift+c to reload the configuration.

uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)

temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
temp=$(($temp_raw / 1000))

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
# if [ "$MUTED" = "yes" ]; then // TODO
#     echo "🔇 Muted"
# else
#     echo "🔊 $VOLUME"
# fi

battery_status=$(cat /sys/class/power_supply/BAT0/status) # "Full", "Discharging", or "Charging"
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity) # %

# date and time format: Tue 2025-08-19 22:37
datetime=$(date "+%a %F %H:%M:%S")

interface=$(ip route get 8.8.8.8 | awk -F'dev ' 'NR==1{split($2,a," ");print a[1]}')
ip=$(ip addr show dev $interface | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

avail_space=$(df -h / | awk 'NR==2 {print $4}')




# 💎 💻 💡 🔌 ⚡ 📁 \| 🐧 🔊 🔋
echo $avail_space \| $temp°C \| $uptime_formatted \| vol: $volume $muted \| $battery_status $battery_capacity% \| $interface $ip \| $datetime
