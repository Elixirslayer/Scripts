#!/bin/zsh

# Get the list of active players
players=$(playerctl -l 2>/dev/null)

# Count the number of players
player_count=$(echo "$players" | wc -l)

if [ "$player_count" -eq 1 ]; then
    # If only one player, go to previous track
    playerctl --player=$players previous
elif [ "$player_count" -gt 1 ]; then
    # If multiple players, list them with rofi for selection
    chosen_player=$(echo "$players" | rofi -dmenu -p "Select player to skip previous:")
    if [ -n "$chosen_player" ]; then
        playerctl --player=$chosen_player previous
    fi
else
    # No active players
    notify-send "Playerctl" "No active media players found!"
fi

