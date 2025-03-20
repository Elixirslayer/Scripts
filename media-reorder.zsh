#!/bin/zsh

# Config file to save player order
order_file="$HOME/.config/playerctl_order"

# Get the list of active players
players=$(playerctl -l 2>/dev/null)

# Load the saved order if the file exists
if [ -f "$order_file" ]; then
    ordered_players=($(cat "$order_file"))
    # Retain only currently active players from the saved order
    ordered_players=("${(@)ordered_players:#${(j:|:)players}}")
    # Append newly active players not in the saved order
    for player in ${(f)players}; do
        if [[ ! " ${ordered_players[@]} " =~ " $player " ]]; then
            ordered_players+=("$player")
        fi
    done
else
    # If no order file, use the current order
    ordered_players=("${(f)players}")
fi

# Save the updated order
echo "$ordered_players" > "$order_file"

# Reorder Players
new_order=$(printf "%s\n" "${ordered_players[@]}" | rofi -dmenu -p "Reorder players (drag to rearrange):" -multi-select)
if [ -n "$new_order" ]; then
    echo "$new_order" > "$order_file"
fi

