#!/bin/zsh

# Directory to save screenshots
DIR="/home/oc/Screenshots"
# Filename for the screenshot
FILE="$DIR/screenshot-$(date +%Y-%m-%d-%H-%M).png"

# Create the screenshots directory if it doesn't exist
mkdir -p "$DIR"

# Take a full screenshot and save it
maim "$FILE"

# Copy the screenshot to clipboard
xclip -selection clipboard -t image/png -i "$FILE"

# Send a notification
notify-send "Screenshot saved" "$FILE"

