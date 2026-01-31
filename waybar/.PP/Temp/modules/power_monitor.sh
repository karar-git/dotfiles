#!/bin/bash

# ~/.config/waybar/scripts/power_monitor.sh

# Get battery voltage information
get_battery_voltage() {
    local battery_dir=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
    if [[ -d "$battery_dir" ]]; then
        # Read voltage values (in microvolts)
        local voltage_now=$(cat "$battery_dir/voltage_now" 2>/dev/null)
        local design_voltage=$(cat "$battery_dir/voltage_min_design" 2>/dev/null)
        
        # Convert to volts if we have valid values
        if [[ -n "$voltage_now" && "$voltage_now" -gt 0 ]]; then
            local voltage_v=$(awk "BEGIN {printf \"%.2f\", $voltage_now / 1000000}")
            echo "$voltage_v V"
            return
        fi
        
        # Fallback to design voltage if current voltage unavailable
        if [[ -n "$design_voltage" && "$design_voltage" -gt 0 ]]; then
            local voltage_v=$(awk "BEGIN {printf \"%.2f\", $design_voltage / 1000000}")
            echo "$voltage_v V (design)"
            return
        fi
    fi
    
    # Final fallback
    echo "N/A"
}

# Get battery status and percentage
get_battery_status() {
    local status_file=$(ls /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
    if [[ -f "$status_file" ]]; then
        cat "$status_file" 2>/dev/null | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

get_battery_percentage() {
    local capacity_file=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
    if [[ -f "$capacity_file" ]]; then
        cat "$capacity_file" 2>/dev/null
    else
        echo "N/A"
    fi
}

# Check if AC adapter is connected
is_ac_connected() {
    for ac in /sys/class/power_supply/A{C,DP}*; do
        if [[ -d "$ac" && -f "$ac/online" ]]; then
            [[ $(cat "$ac/online" 2>/dev/null) == "1" ]] && return 0
        fi
    done
    return 1
}

# Main execution
voltage=$(get_battery_voltage)
status=$(get_battery_status)
percentage=$(get_battery_percentage)

# Format the output
text="$voltage"

# Create tooltip based on power source
if is_ac_connected; then
    tooltip="🔌 AC Connected | Voltage: $voltage | Battery: ${percentage}% (${status})"
else
    tooltip="🔋 Battery Voltage: $voltage | ${percentage}% (${status})"
fi

# Output JSON for waybar
printf '{"text": "%s", "tooltip": "%s", "class": "power-monitor"}\n' "$text" "$tooltip"
