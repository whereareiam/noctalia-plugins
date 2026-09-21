#!/usr/bin/env bash

set -euo pipefail

payload="${1-}"
if [[ -z "$payload" ]]; then
    payload='{}'
fi

normalize_address() {
    local id="${1:-}"

    if [[ -z "$id" ]]; then
        return 1
    fi

    if [[ "$id" == 0x* ]]; then
        printf '%s\n' "$id"
        return 0
    fi

    printf '0x%s\n' "$id"
}

target_window_id="$(jq -r '.targetWindowId // .primaryWindowId // empty' <<<"$payload")"

if [[ -z "$target_window_id" ]]; then
    active_address="$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')"
    target_window_id="$active_address"
fi

address="$(normalize_address "$target_window_id")" || exit 0
hyprctl dispatch "hl.dsp.window.close({ window = \"address:${address}\" })"
