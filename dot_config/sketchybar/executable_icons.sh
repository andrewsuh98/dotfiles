#!/bin/bash

# Nerd Font icons
export ICON_APPLE=""
export ICON_CLOCK=""
export ICON_CALENDAR=""
export ICON_WIFI=""
export ICON_WIFI_OFF="󰤭"
export ICON_VOLUME_HIGH="󰕾"
export ICON_VOLUME_MED="󰖀"
export ICON_VOLUME_LOW="󰕿"
export ICON_VOLUME_MUTE="󰝟"
export ICON_BATTERY_100="󰁹"
export ICON_BATTERY_75="󰂁"
export ICON_BATTERY_50="󰁾"
export ICON_BATTERY_25="󰁻"
export ICON_BATTERY_0="󰂎"
export ICON_BATTERY_CHARGING="󰂄"
export ICON_CPU="󰻠"
export ICON_MEMORY="󰍛"
export ICON_MEDIA="󰎈"
export ICON_MEDIA_PAUSE="󰏤"
export ICON_APP=""

# App icon mapping (Nerd Font glyphs)
app_icon() {
  case "$1" in
    "Arc") echo "󰖟" ;;
    "Kitty"|"Terminal") echo "" ;;
    "Code"|"Visual Studio Code") echo "󰨞" ;;
    "Obsidian") echo "󱓧" ;;
    "Claude") echo "󰧑" ;;
    "Finder") echo "󰀶" ;;
    "Spark") echo "󰇮" ;;
    "Things"|"Things 3") echo "󰄵" ;;
    "Fantastical") echo "" ;;
    "Discord") echo "󰙯" ;;
    "WhatsApp") echo "󰖣" ;;
    "Messages") echo "󰍡" ;;
    "KakaoTalk") echo "󰍡" ;;
    "Safari") echo "󰀹" ;;
    "Preview") echo "" ;;
    "System Settings"|"System Preferences") echo "" ;;
    "Spotify") echo "" ;;
    "Music") echo "󰎈" ;;
    "FaceTime") echo "󰍢" ;;
    "1Password") echo "󰌋" ;;
    *) echo "$ICON_APP" ;;
  esac
}
