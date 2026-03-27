# whereareiam's Noctalia Plugins

Some collection of maybe useful plugins for Noctalia.

## Add This Repository As a Source

1. Open Noctalia.
2. Go to the plugins section.
3. Add a custom plugin source.
4. Use the repository URL of this source repo, for example:

```text
https://github.com/whereareiam/noctalia-plugins
```

5. Refresh plugin sources.
6. Install the plugin you want from the list.

## Plugins

<details>
<summary><strong>Tabber</strong> — macOS like window switcher</summary>

<img width="1293" height="515" alt="Tabber showcase" src="https://github.com/user-attachments/assets/eb4d1e80-e864-4eca-aee1-750f43a31745" />

### What it does

Tabber provides an Alt-Tab style switcher for Noctalia on Hyprland.

It supports:
- grouped mode: windows from the same app appear as one item
- normal mode: every window appears as its own item
- custom actions
- optional hidden-window restore

### Requirements

- `qs`
- `hyprctl`
- `jq`

### After installation

Tabber still needs Hyprland keybinds to trigger it.

Example Hyprland wiring:

```ini
bind = ALT, Tab, global, tabber:select-next
bind = ALT SHIFT, Tab, global, tabber:select-previous
bind = , Alt_L, global, tabber:release-alt-left
bind = , Alt_R, global, tabber:release-alt-right
```

Optional direct action binds via the generic action IPC:

```ini
bind = ALT, Q, exec, qs ipc -c noctalia-shell call plugin:tabber action close
bind = ALT, H, exec, qs ipc -c noctalia-shell call plugin:tabber action hide
```

</details>
