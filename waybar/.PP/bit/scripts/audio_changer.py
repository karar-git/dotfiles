#!/usr/bin/env python3
import subprocess
import sys
import json
from typing import List, Dict, Optional

# Rofi configuration
ROFI_THEME = "dmenu"  # You can change this to your preferred theme
ROFI_OPTS = f"-dmenu -i -p 'Select Audio Sink' -theme {ROFI_THEME}"
ROFI_SIZE_POS = "-location 1 -width 30 -lines 10"  # top-left, adjust as needed

def run_command(command: str) -> Optional[str]:
    """Execute a shell command and return its output, or None if it fails."""
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            capture_output=True, 
            text=True, 
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error executing command '{command}': {e}", file=sys.stderr)
        return None

def parse_wpctl_status() -> List[Dict[str, any]]:
    """Parse wpctl status output and return a list of sink dictionaries."""
    output = run_command("wpctl status")
    if not output:
        print("Failed to get wpctl status", file=sys.stderr)
        sys.exit(1)
    
    # Clean up ASCII tree characters
    lines = [
        line.replace("├", "").replace("─", "").replace("│", "").replace("└", "")
        for line in output.splitlines()
    ]
    
    # Find the Sinks section
    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break
    
    if sinks_index is None:
        print("Could not find Sinks section in wpctl output", file=sys.stderr)
        sys.exit(1)
    
    # Extract sink lines until we hit a blank line or another section
    raw_sinks = []
    for line in lines[sinks_index + 1:]:
        line = line.strip()
        if not line or line.endswith(":"):  # Empty line or new section
            break
        raw_sinks.append(line)
    
    # Parse sink information
    sinks = []
    for sink_line in raw_sinks:
        try:
            # Remove volume information
            sink_clean = sink_line.split("[vol:")[0].strip()
            
            # Check if it's the default sink
            is_default = sink_clean.startswith("*")
            if is_default:
                sink_clean = sink_clean[1:].strip()  # Remove asterisk
            
            # Extract ID and name
            parts = sink_clean.split(".", 1)
            if len(parts) >= 2:
                sink_id = int(parts[0])
                sink_name = parts[1].strip()
                
                sinks.append({
                    "sink_id": sink_id,
                    "sink_name": sink_name,
                    "is_default": is_default
                })
        except (ValueError, IndexError) as e:
            print(f"Warning: Could not parse sink line '{sink_line}': {e}", file=sys.stderr)
            continue
    
    return sinks

def format_sink_list(sinks: List[Dict[str, any]]) -> str:
    """Format the sink list for rofi display."""
    output_lines = []
    
    for sink in sinks:
        name = sink['sink_name']
        if sink['is_default']:
            # Use rofi markup for highlighting default sink
            output_lines.append(f"<b>→ {name} (Default)</b>")
        else:
            output_lines.append(name)
    
    return '\n'.join(output_lines)

def show_rofi_menu(sinks: List[Dict[str, any]]) -> Optional[str]:
    """Display rofi menu and return selected sink name."""
    formatted_output = format_sink_list(sinks)
    
    # Build rofi command with markup support
    rofi_command = f"echo '{formatted_output}' | rofi {ROFI_OPTS} {ROFI_SIZE_POS} -markup-rows"
    
    try:
        result = subprocess.run(
            rofi_command,
            shell=True,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return None  # User cancelled
            
        return result.stdout.strip()
    except Exception as e:
        print(f"Error running rofi: {e}", file=sys.stderr)
        return None

def find_sink_by_display_name(sinks: List[Dict[str, any]], display_name: str) -> Optional[Dict[str, any]]:
    """Find sink by its display name (accounting for default formatting)."""
    # Clean the display name (remove markup and default indicators)
    clean_name = (display_name
                  .replace("<b>", "")
                  .replace("</b>", "")
                  .replace("→ ", "")
                  .replace(" (Default)", "")
                  .strip())
    
    for sink in sinks:
        if sink['sink_name'] == clean_name:
            return sink
    
    return None

def set_default_sink(sink_id: int) -> bool:
    """Set the default audio sink."""
    command = f"wpctl set-default {sink_id}"
    result = run_command(command)
    return result is not None

def show_notification(message: str):
    """Show a desktop notification if notify-send is available."""
    try:
        subprocess.run(
            ["notify-send", "Audio Sink Switcher", message],
            check=True,
            capture_output=True
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        # notify-send not available or failed, just print to stdout
        print(message)

def main():
    """Main function."""
    try:
        # Parse current sinks
        sinks = parse_wpctl_status()
        
        if not sinks:
            print("No audio sinks found", file=sys.stderr)
            sys.exit(1)
        
        # Show rofi menu
        selected_display_name = show_rofi_menu(sinks)
        
        if not selected_display_name:
            print("Operation cancelled by user")
            sys.exit(0)
        
        # Find the selected sink
        selected_sink = find_sink_by_display_name(sinks, selected_display_name)
        
        if not selected_sink:
            print(f"Could not find sink matching '{selected_display_name}'", file=sys.stderr)
            sys.exit(1)
        
        # Set as default if it's not already
        if not selected_sink['is_default']:
            if set_default_sink(selected_sink['sink_id']):
                message = f"Set '{selected_sink['sink_name']}' as default audio sink"
                show_notification(message)
            else:
                print(f"Failed to set {selected_sink['sink_name']} as default", file=sys.stderr)
                sys.exit(1)
        else:
            message = f"'{selected_sink['sink_name']}' is already the default sink"
            show_notification(message)
    
    except KeyboardInterrupt:
        print("\nOperation cancelled")
        sys.exit(0)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
