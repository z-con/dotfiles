#!/bin/bash
BAT=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)

if   [ "$STATUS" = "Full" ];     then ICON=""
elif [ "$STATUS" = "Charging" ]; then
  if   [ $BAT -ge 90 ]; then ICON="󰂅"
  elif [ $BAT -ge 80 ]; then ICON="󰂋"
  elif [ $BAT -ge 70 ]; then ICON="󰂊"
  elif [ $BAT -ge 60 ]; then ICON="󰢞"
  elif [ $BAT -ge 50 ]; then ICON="󰂉"
  elif [ $BAT -ge 40 ]; then ICON="󰢝"
  elif [ $BAT -ge 30 ]; then ICON="󰂈"
  elif [ $BAT -ge 20 ]; then ICON="󰂇"
  elif [ $BAT -ge 10 ]; then ICON="󰂆"
  else                       ICON="󰢜"
  fi
else
  if   [ $BAT -ge 90 ]; then ICON="󰁹"
  elif [ $BAT -ge 80 ]; then ICON="󰂂"
  elif [ $BAT -ge 70 ]; then ICON="󰂁"
  elif [ $BAT -ge 60 ]; then ICON="󰂀"
  elif [ $BAT -ge 50 ]; then ICON="󰁿"
  elif [ $BAT -ge 40 ]; then ICON="󰁾"
  elif [ $BAT -ge 30 ]; then ICON="󰁽"
  elif [ $BAT -ge 20 ]; then ICON="󰁼"
  elif [ $BAT -ge 10 ]; then ICON="󰁻"
  else                       ICON="󰁺"
  fi
fi

echo "$ICON $BAT%"
