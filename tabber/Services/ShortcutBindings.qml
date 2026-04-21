import QtQuick
import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "../Utils/ActionUtils.js" as ActionUtils

Item {
    id: root

    required property var controller

    visible: false

    IpcHandler {
        target: "plugin:tabber"

        function trigger(direction: string) {
            root.controller.trigger(direction === "previous" ? "previous" : "next", "ipc");
        }

        function hide() {
            root.controller.hideOverlay(false);
        }

        function accept() {
            root.controller.acceptSelection();
        }

        function enterGroup() {
            root.controller.enterSelectedGroup();
        }

        function enterGroupDebug(): string {
            return root.controller.enterSelectedGroupDebug();
        }

        function action(actionId: string) {
            root.controller.runActionById(actionId);
        }

        function debugState(): string {
            return root.controller.debugState();
        }
    }

    GlobalShortcut {
        appid: "tabber"
        name: "select-next"
        description: "Tabber select next item"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("next", "global-shortcut-alt")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "select-previous"
        description: "Tabber select previous item"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("previous", "global-shortcut-alt")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "select-next-super"
        description: "Tabber select next item (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("next", "global-shortcut-super")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "select-previous-super"
        description: "Tabber select previous item (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("previous", "global-shortcut-super")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "release-alt-left"
        description: "Tabber modifier release tracker"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Alt)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "release-alt-right"
        description: "Tabber modifier release tracker"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Alt)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "release-super-left"
        description: "Tabber modifier release tracker (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Meta)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "release-super-right"
        description: "Tabber modifier release tracker (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Meta)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "enter-group"
        description: "Tabber enter selected group"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.enterSelectedGroup()
    }

    // Legacy aliases for existing Hyprland configs.
    GlobalShortcut {
        appid: "tabber"
        name: "trigger-next-alt"
        description: "Tabber select next item"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("next", "global-shortcut-alt")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "trigger-previous-alt"
        description: "Tabber select previous item"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("previous", "global-shortcut-alt")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "trigger-next-super"
        description: "Tabber select next item (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("next", "global-shortcut-super")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "trigger-previous-super"
        description: "Tabber select previous item (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onPressed: root.controller.trigger("previous", "global-shortcut-super")
    }

    GlobalShortcut {
        appid: "tabber"
        name: "modifier-alt-left"
        description: "Tabber modifier release tracker"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Alt)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "modifier-alt-right"
        description: "Tabber modifier release tracker"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Alt)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "modifier-super-left"
        description: "Tabber modifier release tracker (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Meta)
    }

    GlobalShortcut {
        appid: "tabber"
        name: "modifier-super-right"
        description: "Tabber modifier release tracker (Super binding)"
        triggerDescription: "Configured in Hyprland"
        onReleased: root.controller.handleGlobalModifierRelease(Qt.Key_Meta)
    }

    Instantiator {
        active: root.controller && root.controller.session && root.controller.session.overlayVisible && root.controller.actionRegistry
        model: root.controller && root.controller.actionRegistry ? root.controller.actionRegistry.overlayShortcutActions : []

        delegate: GlobalShortcut {
            required property var modelData
            required property int index

            appid: "tabber"
            name: "overlay-action-" + ActionUtils.shortcutNameSegment(modelData, index)
            description: ActionUtils.tabberActionDisplayName(modelData, index)
            triggerDescription: String(modelData.overlayKeybind || "")
            onPressed: root.controller.runActionById(String(modelData.id || ""))
        }
    }
}
