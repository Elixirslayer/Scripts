#!/usr/bin/env bash

histfile="$HOME/.cache/cliphist"
placeholder="<NEWLINE>"

highlight() {
  clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard 2>/dev/null)
}

output() {
  clip=$(xclip -i -f -selection clipboard 2>/dev/null)
}

write() {
  [ -f "$histfile" ] || notify-send "Creating $histfile"; touch "$histfile"
  [ -z "$clip" ] && exit 0
  multiline=$(echo "$clip" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')

  # Remove duplicate (if it exists), then re-add at the top of regular items
  sed -i "\|^$multiline$|d" "$histfile"
  echo "$multiline" >> "$histfile"

  notification="Saved to clipboard history!"
}

sel() {
  # Get pinned items, ignoring empty lines
  pinned_items=$(grep "^PINNED:" "$histfile" | sed 's/^PINNED://' | grep -v '^[[:space:]]*$')

  # Get regular items, ignoring empty lines and reversing the order
  regular_items=$(grep -v "^PINNED:" "$histfile" | tac | grep -v '^[[:space:]]*$')

  # Merge pinned + regular items, ensuring no extra newlines
  combined_items=$(printf "%s\n%s" "$pinned_items" "$regular_items" | awk 'NF')

  selection=$(echo "$combined_items" | dmenu -b -l 5 -i -p "Clipboard history:")
  if [ -n "$selection" ]; then
    echo "$selection" | sed "s/$placeholder/\n/g" | xclip -i -selection clipboard
    notification="Copied to clipboard!"
  fi
}

pin() {
  selection=$(tac "$histfile" | dmenu -b -l 5 -i -p "Pin item:")
  if [ -n "$selection" ]; then
    # Process text for multiline storage
    formatted_selection=$(echo "$selection" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')

    # Remove it from both pinned and regular sections
    sed -i "\|^PINNED:$formatted_selection$|d" "$histfile"
    sed -i "\|^$formatted_selection$|d" "$histfile"

    # Add to pinned section
    echo "PINNED:$formatted_selection" >> "$histfile"
    notification="Pinned: $selection"
  fi
}

unpin() {
  selection=$(grep "^PINNED:" "$histfile" | sed 's/^PINNED://' | dmenu -b -l 5 -i -p "Unpin item:")
  if [ -n "$selection" ]; then
    # Process text for multiline storage
    formatted_selection=$(echo "$selection" | sed ':a;N;$!ba;s/\n/'"$placeholder"'/g')

    # Remove from pinned section
    sed -i "\|^PINNED:$formatted_selection$|d" "$histfile"

    # Re-add to the top of the regular section
    echo "$formatted_selection" >> "$histfile"
    notification="Unpinned: $selection"
  fi
}

case "$1" in
  add) highlight && write ;;
  out) output && write ;;
  sel) sel ;;
  pin) pin ;;
  unpin) unpin ;;
  *) printf "$0 | File: $histfile\n\nadd - copies primary selection to clipboard, and adds to history file\nout - pipe commands to copy output to clipboard, and add to history file\nsel - select from history file with dmenu and recopy!\npin - pin an item to the top\nunpin - unpin an item\n" ; exit 0 ;;
esac

notify-send "$notification"

