#!/usr/bin/env bash

# ==========================
# MULTI-COLOR TERMINAL
# ==========================

colors=(
    $(tput setaf 1)  # Red
    $(tput setaf 2)  # Green
    $(tput setaf 3)  # Yellow
    $(tput setaf 4)  # Blue
    $(tput setaf 5)  # Magenta
    $(tput setaf 6)  # Cyan
)
reset=$(tput sgr0)

get_random_color() {
    echo -n "${colors[$RANDOM % ${#colors[@]}]}"
}

type_effect () {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -n "$(get_random_color)${text:$i:1}${reset}"
        sleep 0.01
    done
    echo ""
}

spinner() {
    local pid=$!
    local delay=0.1
    local spin="|/-\\"
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "$(get_random_color)[${spin:$i:1}] Installing...${reset}\r"
            sleep $delay
        done
    done
    echo -ne "                          \r"
}

clear

echo ""
type_effect "███ HACKING WIDGETS SUBSYSTEM ███"
type_effect ">>> Establishing secure SSH tunnel..."
sleep 0.3
type_effect ">>> Injecting files into Flutter core..."
sleep 0.4
echo ""

BASE_DIR="lib/core/widgets"

(
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
fi
) & spinner

echo ""
type_effect "✔ Directory verified: $BASE_DIR"
sleep 0.2

type_effect ">>> Writing: common_app_bar.dart"
sleep 0.3

cat > "$BASE_DIR/common_app_bar.dart" <<EOF
... (your existing Dart code here unchanged)
EOF

sleep 0.3
type_effect "✔ common_app_bar.dart injected"
sleep 0.2

type_effect ">>> Writing: text_widget.dart"
sleep 0.3

cat > "$BASE_DIR/text_widget.dart" <<EOF
... (your existing Dart code here unchanged)
EOF

sleep 0.3
type_effect "✔ text_widget.dart injected"
sleep 0.2

echo ""
type_effect ">>> Finalizing..."
sleep 0.3
type_effect ">>> Clearing traces..."
sleep 0.2
type_effect ">>> Logging out..."
sleep 0.5

echo ""
type_effect "███ OPERATION COMPLETED — SYSTEM SECURE ███"
echo ""
