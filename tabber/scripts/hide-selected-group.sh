#!/usr/bin/env bash

set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr-hidden-window"
state_file="$state_dir/hidden-windows.json"
hidden_workspace="special:hidden"

mkdir -p "$state_dir"

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

load_state() {
    if [[ -f "$state_file" ]]; then
        jq -c '.' "$state_file" 2>/dev/null || echo '[]'
    else
        echo '[]'
    fi
}

save_state() {
    local new_state="$1"
    printf '%s\n' "$new_state" >"$state_file"
}

client_by_address() {
    local address="$1"

    hyprctl clients -j 2>/dev/null | jq -c \
        --arg address "$address" '
        [
          .[]
          | select(.address == $address and .mapped == true)
        ] | last // empty
    '
}

hidden_client_matches() {
    local app_id="$1"
    local title="$2"

    hyprctl clients -j 2>/dev/null | jq -c \
        --arg workspace "$hidden_workspace" \
        --arg app_id "$app_id" \
        --arg title "$title" '
        [
          .[]
          | select(.workspace.name == $workspace and .mapped == true)
          | select(
              (($app_id == "") or (.class == $app_id))
              and (($title == "") or (.title == $title))
            )
        ] | last // empty
    '
}

remove_entry() {
    local state_json="$1"
    local address="$2"

    jq -c --arg address "$address" '
        map(select(.address != $address))
    ' <<<"$state_json"
}

upsert_entry() {
    local state_json="$1"
    local address="$2"
    local workspace="$3"
    local title="$4"
    local app_id="$5"

    jq -c \
        --arg address "$address" \
        --arg workspace "$workspace" \
        --arg title "$title" \
        --arg app_id "$app_id" '
        (map(select(.address != $address))) + [{
            address: $address,
            workspace: $workspace,
            title: $title,
            app_id: $app_id
        }]
    ' <<<"$state_json"
}

select_hidden_entry() {
    local state_json="$1"
    local mode="$2"
    local match_value="${3:-}"
    local match_title="${4:-}"

    if [[ -n "$match_value" && "$mode" == "restore-by-address" ]]; then
        jq -c --arg address "$match_value" '
            map(select(.address == $address)) | last // empty
        ' <<<"$state_json"
        return
    fi

    if [[ -n "$match_value" || -n "$match_title" ]]; then
        jq -c \
            --arg app_id "$match_value" \
            --arg title "$match_title" '
            map(select(
                (($app_id == "") or (.app_id == $app_id))
                and (($title == "") or (.title == $title))
            )) | last // empty
        ' <<<"$state_json"
    else
        jq -c 'last // empty' <<<"$state_json"
    fi
}

hide_window() {
    local client_json="$1"
    local state_json target_address target_workspace target_title target_app_id

    target_address="$(jq -r '.address // empty' <<<"$client_json")"
    target_workspace="$(jq -r '.workspace.name // empty' <<<"$client_json")"
    target_title="$(jq -r '.title // empty' <<<"$client_json")"
    target_app_id="$(jq -r '.class // empty' <<<"$client_json")"

    if [[ -z "$target_address" || "$target_workspace" == "$hidden_workspace" ]]; then
        return 0
    fi

    state_json="$(load_state)"
    state_json="$(upsert_entry "$state_json" "$target_address" "$target_workspace" "$target_title" "$target_app_id")"
    save_state "$state_json"

    hyprctl dispatch movetoworkspacesilent "$hidden_workspace,address:$target_address" >/dev/null 2>&1 || true
}

restore_hidden_window() {
    local mode="$1"
    local match_value="${2:-}"
    local match_title="${3:-}"
    local state_json hidden_json fallback_json hidden_address hidden_from_workspace
    local active_workspace_json active_workspace_name target_workspace

    state_json="$(load_state)"
    hidden_json="$(select_hidden_entry "$state_json" "$mode" "$match_value" "$match_title")"

    if [[ -z "${hidden_json:-}" || "$hidden_json" == "null" ]]; then
        if [[ "$mode" == "restore-by-address" ]]; then
            fallback_json="$(hyprctl clients -j 2>/dev/null | jq -c \
                --arg workspace "$hidden_workspace" \
                --arg address "$match_value" '
                [
                  .[]
                  | select(.workspace.name == $workspace and .mapped == true and .address == $address)
                ] | last // empty
            ')"
        else
            fallback_json="$(hidden_client_matches "$match_value" "$match_title")"
        fi

        if [[ -n "${fallback_json:-}" && "$fallback_json" != "null" ]]; then
            hidden_json="$(jq -c '{
                address: .address,
                workspace: "1",
                title: .title,
                app_id: .class
            }' <<<"$fallback_json")"
        else
            return 0
        fi
    fi

    hidden_address="$(jq -r '.address // empty' <<<"$hidden_json")"
    hidden_from_workspace="$(jq -r '.workspace // empty' <<<"$hidden_json")"
    if [[ -z "$hidden_address" ]]; then
        return 0
    fi

    active_workspace_json="$(hyprctl activeworkspace -j 2>/dev/null || true)"
    active_workspace_name="$(jq -r '.name // empty' <<<"$active_workspace_json")"
    target_workspace="${active_workspace_name:-${hidden_from_workspace:-1}}"

    hyprctl dispatch movetoworkspacesilent "$target_workspace,address:$hidden_address" >/dev/null 2>&1 || true
    hyprctl dispatch focuswindow "address:$hidden_address" >/dev/null 2>&1 || true
    hyprctl dispatch alterzorder "top,address:$hidden_address" >/dev/null 2>&1 || true

    state_json="$(remove_entry "$state_json" "$hidden_address")"
    save_state "$state_json"
}

toggle_active_window() {
    local active_window_json active_workspace_json active_address active_workspace_name client_json

    active_window_json="$(hyprctl activewindow -j 2>/dev/null || true)"
    active_workspace_json="$(hyprctl activeworkspace -j 2>/dev/null || true)"
    active_address="$(jq -r '.address // empty' <<<"$active_window_json")"
    active_workspace_name="$(jq -r '.name // empty' <<<"$active_workspace_json")"

    if [[ -n "$active_address" && "$active_workspace_name" != "$hidden_workspace" ]]; then
        client_json="$(client_by_address "$active_address")"
        if [[ -n "${client_json:-}" && "$client_json" != "null" ]]; then
            hide_window "$client_json"
        fi
        return 0
    fi

    restore_hidden_window "toggle"
}

handle_payload_mode() {
    local payload="$1"
    local normalized_payload window_ids address client_json

    normalized_payload="$payload"
    if [[ -z "$normalized_payload" ]]; then
      normalized_payload='{}'
    fi

    mapfile -t window_ids < <(jq -r '.windows[]?.id // empty' <<<"$normalized_payload")

    if [[ ${#window_ids[@]} -eq 0 ]]; then
        toggle_active_window
        return 0
    fi

    for window_id in "${window_ids[@]}"; do
        address="$(normalize_address "$window_id")" || continue
        client_json="$(client_by_address "$address")"
        if [[ -z "${client_json:-}" || "$client_json" == "null" ]]; then
            continue
        fi
        hide_window "$client_json"
    done
}

first_arg="${1-}"

case "$first_arg" in
    ""|"{"*|"["*)
        handle_payload_mode "$first_arg"
        ;;
    restore-if-match)
        restore_hidden_window "restore-if-match" "${2:-}" "${3:-}"
        ;;
    restore-by-address)
        restore_hidden_window "restore-by-address" "${2:-}"
        ;;
    hide-by-address)
        address="$(normalize_address "${2:-}")" || exit 0
        client_json="$(client_by_address "$address")"
        if [[ -n "${client_json:-}" && "$client_json" != "null" ]]; then
            hide_window "$client_json"
        fi
        ;;
    toggle)
        toggle_active_window
        ;;
    *)
        handle_payload_mode "$first_arg"
        ;;
esac
