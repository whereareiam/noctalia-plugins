# whereareiam's Noctalia v5 plugins

This repository contains two native Noctalia v5 plugins for Hyprland:

- `whereareiam/veil` hides focused windows in `special:hidden` and restores or closes them from a panel.
- `whereareiam/tabber` provides a grouped Alt-Tab-style switcher with configurable appearance, actions, and Veil integration.

## Install

Add this repository as a plugin source in Noctalia, then enable the plugins:

```sh
noctalia msg plugins source add whereareiam git https://github.com/whereareiam/noctalia-plugins
noctalia msg plugins enable whereareiam/veil
noctalia msg plugins enable whereareiam/tabber
```

For local development, use a path source instead:

```sh
noctalia msg plugins source add whereareiam-dev path /path/to/noctalia-plugins
```

## Veil

Add the `whereareiam/veil:bar` widget to a bar. The widget opens the restore panel and shows the number of hidden windows.
The service also exposes these events:

```sh
noctalia msg plugin whereareiam/veil:service all toggle-focused
noctalia msg plugin whereareiam/veil:service all open-restore-menu
```

Example Hyprland bindings (Super is owned by Hyprland; Noctalia panels cannot capture it):

```ini
bind = SUPER, H, exec, noctalia msg plugin whereareiam/veil:service all toggle-focused
bind = SUPER SHIFT, H, exec, noctalia msg plugin whereareiam/veil:service all open-restore-menu
```

## Tabber

Tabber uses the `whereareiam/tabber:service` entry for compositor state and the `whereareiam/tabber:overlay` panel for the UI.
Use compositor IPC bindings for the Super workflow. The release binding is important: it accepts the selected item when
Super is released, while repeated Super+Tab presses continue cycling.

```ini
bind = SUPER, Tab, exec, noctalia msg plugin whereareiam/tabber:service all next
bind = SUPER SHIFT, Tab, exec, noctalia msg plugin whereareiam/tabber:service all previous
bind = SUPER, Grave, exec, noctalia msg plugin whereareiam/tabber:service all enter-group
bindr = SUPER, Tab, exec, noctalia msg plugin whereareiam/tabber:service all trigger-release
bindr = SUPER SHIFT, Tab, exec, noctalia msg plugin whereareiam/tabber:service all trigger-release
bindr = , SUPER_L, exec, noctalia msg plugin whereareiam/tabber:service all accept
bindr = , SUPER_R, exec, noctalia msg plugin whereareiam/tabber:service all accept
bind = SUPER, Q, exec, noctalia msg plugin whereareiam/tabber:service all action close
```

The modifier-release bindings must use an empty modifier field (`, SUPER_L` / `, SUPER_R`).
Do not register them as `SUPER_L` with Super as the modifier: that binding is not matched
when Super is released while Tab is still held, which leaves the switcher open.

When using Hyprland's Lua config, `hl.bind("Super_L", ..., { release = true })` has the
same problem because the Lua parser treats `Super_L` as a sided modifier. Bind the raw
keycodes instead:

```lua
bind("code:133", hl.dsp.exec_cmd("noctalia msg plugin whereareiam/tabber:service all accept"), { release = true, ignore_mods = true }) -- Super_L
bind("code:134", hl.dsp.exec_cmd("noctalia msg plugin whereareiam/tabber:service all accept"), { release = true, ignore_mods = true }) -- Super_R
```

The panel captures Tab, Shift+Tab, Grave, and Alt release while it is focused. Actions are intentionally hooked through
the service IPC, so any compositor keybind or external hook can trigger an action by ID. Tabber reads the action map
from `~/.local/state/noctalia/plugins/data/whereareiam/tabber/actions.json`:

```json
{
  "close": "scripts/close-selected-group.sh"
}
```

Each key is the action ID used after `action`, and each value is an executable path. `Super+Q` works both with the
overlay selection and, when the overlay is closed, with the compositor-focused group. `Super+H` works the
same way through Veil: outside Tabber it hides the focused window; inside Tabber it toggles the selected window because
Tabber publishes its target through the integration provider API.

Tabber passes each action script one JSON payload containing the selected group and its windows.

Tabber and Veil share the runtime state file at `$XDG_RUNTIME_DIR/veil/hidden-windows.json`; when Veil is enabled, hidden
windows appear as highlighted switcher cards and selecting one restores it.
