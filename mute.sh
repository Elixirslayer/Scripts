#!/usr/bin/zsh

# Get list of sink inputs with application names, volumes, and mute status
sink_inputs=$(pactl list sink-inputs | awk -v RS='' -F '\n' '{
    sink_input_id = ""
    application = "unknown"
    volume = "unknown"
    mute = "no"
    for (i=1; i<=NF; i++) {
        if ($i ~ /Sink Input #/) {
            sub(/.*#/, "", $i)
            sink_input_id = $i
        } else if ($i ~ /application\.name = "/) {
            sub(/.*application\.name = "/, "", $i)
            sub(/".*/, "", $i)
            application = $i
        } else if ($i ~ /Volume: front-left:/) {
            sub(/.*\/ *([0-9]+)%.*/, "\\1", $i)
            volume = $i "%"
        } else if ($i ~ /Mute: /) {
            sub(/.*Mute: /, "", $i)
            mute = $i
        }
    }
    if (sink_input_id != "") {
        print sink_input_id ": " application " (" volume ") [" (mute == "yes" ? "Muted" : "Unmuted") "]"
    }
}')

# Select audio stream using rofi
selected=$(echo "$sink_inputs" | rofi -dmenu -p "Toggle mute for" | cut -d ':' -f 1)
[ -z "$selected" ] && exit

# Toggle mute and refresh dwmblocks
pactl set-sink-input-mute "$selected" toggle && pkill -RTMIN+10 -f 'dwmblocks'
