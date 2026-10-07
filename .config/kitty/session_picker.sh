#!/usr/bin/env bash

SESSION_DIR="$HOME/.local/share/kitty/sessions"
mkdir -p "$SESSION_DIR" || exit 1

selected=$(
    find "$SESSION_DIR" -maxdepth 1 -type f \
        \( -name '*.kitty-session' -o -name '*.kitty_session' -o -name '*.session' \) \
        -printf '%f\n' |
    sed -E 's/\.(kitty-session|kitty_session|session)$//' |
    sort |
    fzf \
        --prompt='󰉋  ' \
        --layout=reverse \
        --border \
        --footer='Enter on no match → create session' \
        --bind='enter:accept-or-print-query'
)

[[ -z "$selected" ]] && exit 0

# Existing session?
file=$(
    find "$SESSION_DIR" -maxdepth 1 -type f \
        \( \
            -name "$selected.kitty-session" -o \
            -name "$selected.kitty_session" -o \
            -name "$selected.session" \
        \) \
        -print -quit
)

if [[ -n "$file" ]]; then
    kitten @ action goto_session "$file"
    exit 0
fi

# No match → create it
[[ "$selected" =~ ^[a-zA-Z0-9._-]+$ ]] || exit 1

file="$SESSION_DIR/$selected.kitty-session"

cat > "$file" <<EOF
layout splits
cd ~
launch
EOF

kitten @ action goto_session "$file"
