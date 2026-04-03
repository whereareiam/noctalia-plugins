import QtQuick
import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    required property var controller
    visible: false

    GlobalShortcut {
        appid: "veil"
        name: "toggle-focused"
        description: "Veil toggle focused window"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.toggleFocused()
    }

    GlobalShortcut {
        appid: "veil"
        name: "open-restore-menu"
        description: "Veil open restore menu"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.openRestoreMenu()
    }
}
