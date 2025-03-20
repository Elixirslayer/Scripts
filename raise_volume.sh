#!/usr/bin/zsh

# Get list of sink inputs with application names and volumes
sink_inputs=$(pactl list sink-inputs | awk -v RS='' -F '\n' '{
    sink_input_id = ""
    application = "unknown"
    volume = "unknown"
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
        }
    }
    if (sink_input_id != "") {
        print sink_input_id ": " application " (" volume ")"
    }
}')

# Select audio stream using rofi
selected=$(echo "$sink_inputs" | rofi -dmenu -p "Raise volume for" | cut -d ':' -f 1)
[ -z "$selected" ] && exit

# Get volume increase amount
amount=$(rofi -dmenu -p "Enter percentage to raise")
[ -z "$amount" ] && exit

# Adjust volume and refresh dwmblocks
pactl set-sink-input-volume "$selected" "+${amount}%" && pkill -RTMIN+10 -f 'dwmblocks'
