#!/bin/zsh
# Prompt for a word or phrase using rofi
PHRASE=$(rofi -dmenu -p "Dictionary Lookup (word or phrase)")

# Exit if no input was given
if [[ -z "$PHRASE" ]]; then
    exit 1
fi

# Fetch the definition using dict (talks to your local dictd server)
# Limiting the output to the first 15 lines for brevity.
RAW_DEF=$(dict "$PHRASE" | head -n 15)

# Filter out unwanted lines
FILTERED_DEF=$(echo "$RAW_DEF" | sed -e '/[0-9]\+ definition found/d' \
                                     -e '/^From /d' \
                                     -e "/^[[:space:]]*${PHRASE}[[:space:]]*$/d"| \
                                     perl -pe "s/\Q$PHRASE\E//g")
# Remove any blank lines and trim whitespace per line
FORMATTED_DEF=$(echo "$FILTERED_DEF" | awk 'NF')

# If nothing remains, use a fallback message
if [[ -z "$FORMATTED_DEF" ]]; then
    FORMATTED_DEF="No definition found for \"$PHRASE\"."
fi

# Wrap the definition in Pango markup
TITLE="${PHRASE}"
BODY="<b>${FORMATTED_DEF}</b>"

# Send the notification
notify-send -t 100000 "$TITLE" "$BODY"

