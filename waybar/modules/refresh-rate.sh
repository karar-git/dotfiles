#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

# Refresh rates to toggle between (high and low)
HIGH_RATE=240
LOW_RATE=60

# Dynamically find the monitor name
MONITOR_NAME=$(hyprctl monitors | grep "Monitor eDP-" | awk '{print $2}' | head -1)

# Safety check: exit if no monitor was found
if [ -z "$MONITOR_NAME" ]; then
    echo "Error: No eDP monitor found."
    exit 1
fi

# Get current resolution from hyprctl
get_current_resolution() {
    hyprctl monitors | grep -A 1 "Monitor $MONITOR_NAME" | grep -oP '\d+x\d+' | head -1
}

# Get current refresh rate from hyprctl
get_current_refresh_rate() {
    hyprctl monitors | grep -A 1 "Monitor $MONITOR_NAME" | grep -o '@[0-9]*\.[0-9]*' | sed 's/@//' | head -1
}

# Update the config file dynamically
update_config_file() {
    local new_rate=$1
    local resolution=$(get_current_resolution)
    
    if [ -f "$CONFIG_FILE" ]; then
        # Replace the refresh rate for eDP monitors, preserving resolution
        sed -i "s/^\(monitor=$MONITOR_NAME,$resolution@\)[0-9.]*\(,.*\)/\1${new_rate}.0\2/" "$CONFIG_FILE"
    else
        echo "Error: Config file not found at $CONFIG_FILE"
    fi
}

# Handle click actions
case $1 in
    toggle)
        # Get current refresh rate and resolution
        CURRENT_RATE=$(get_current_refresh_rate)
        CURRENT_RATE_INT=$(printf "%.0f" "$CURRENT_RATE")
        RESOLUTION=$(get_current_resolution)
        
        if [ "$CURRENT_RATE_INT" -ge "$HIGH_RATE" ] || [ "$CURRENT_RATE_INT" -ge $((HIGH_RATE - 1)) ]; then
            # Switch to low refresh rate
            hyprctl keyword monitor "$MONITOR_NAME,${RESOLUTION}@${LOW_RATE},0x0,1.0" >/dev/null 2>&1
            update_config_file "$LOW_RATE"
            echo "Switched to ${LOW_RATE}Hz"
        else
            # Switch to high refresh rate
            hyprctl keyword monitor "$MONITOR_NAME,${RESOLUTION}@${HIGH_RATE},0x0,1.0" >/dev/null 2>&1
            update_config_file "$HIGH_RATE"
            echo "Switched to ${HIGH_RATE}Hz"
        fi
        ;;
    status)
        # Show current refresh rate
        CURRENT_RATE=$(get_current_refresh_rate)
        CURRENT_RATE_INT=$(printf "%.0f" "$CURRENT_RATE")
        echo "${CURRENT_RATE_INT}Hz"
        ;;
    *)
        # Default: show current status
        CURRENT_RATE=$(get_current_refresh_rate)
        CURRENT_RATE_INT=$(printf "%.0f" "$CURRENT_RATE")
        echo "${CURRENT_RATE_INT}Hz"
        ;;
esac
