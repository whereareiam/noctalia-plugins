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

mapfile -t window_ids < <(jq -r '.windows[]?.id // empty' <<<"$payload")

if [[ ${#window_ids[@]} -eq 0 ]]; then
    active_address="$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')"
    if [[ -n "$active_address" ]]; then
        hyprctl dispatch closewindow "address:${active_address}" >/dev/null 2>&1 || true
    fi
    exit 0
fi

for window_id in "${window_ids[@]}"; do
    address="$(normalize_address "$window_id")" || continue
    hyprctl dispatch closewindow "address:${address}" >/dev/null 2>&1 || true
done
