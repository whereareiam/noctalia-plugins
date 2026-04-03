import QtQuick

import "../../Utils/GroupUtils.js" as GroupUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property var actions: settingsStore ? settingsStore.actions.configuredActions : []
    readonly property var overlayShortcutActions: actions.filter(function (action) {
        return String(action && action.overlayKeybind || "").trim() !== "";
    })

    function findById(actionId) {
        for (var i = 0; i < actions.length; i++) {
            if (actions[i].id === actionId) {
                return actions[i];
            }
        }
        return null;
    }

    function findByOverlayKeybind(keybind) {
        for (var i = 0; i < actions.length; i++) {
            if (actions[i].overlayKeybind === keybind) {
                return actions[i];
            }
        }
        return null;
    }

    function buildGroupPayload(actionId, selectedGroup) {
        if (!selectedGroup) {
            return {
                actionId: actionId, windows: []
            };
        }

        var orderedWindows = (selectedGroup.windows || []).slice();
        if (selectedGroup.primaryWindowId) {
            orderedWindows.sort(function (left, right) {
                if (left.id === selectedGroup.primaryWindowId) {
                    return -1;
                }
                if (right.id === selectedGroup.primaryWindowId) {
                    return 1;
                }
                return 0;
            });
        }

        return {
            actionId: actionId,
            groupId: selectedGroup.groupId,
            appId: selectedGroup.appId,
            primaryWindowId: selectedGroup.primaryWindowId || "",
            title: selectedGroup.primaryTitle,
            windowCount: selectedGroup.windowCount,
            windows: orderedWindows
        };
    }

    function buildWindowPayload(actionId, win) {
        if (!win) {
            return {
                actionId: actionId, windows: []
            };
        }

        const title = win.title || win.appId || "Untitled";
        return {
            actionId: actionId,
            groupId: GroupUtils.normalizeGroupId(win.appId || title || win.id),
            appId: win.appId || "",
            title: title,
            windowCount: 1,
            windows: [{
                id: win.id,
                title: title,
                appId: win.appId || "",
                workspaceId: win.workspaceId,
                output: win.output || "",
                isFocused: win.isFocused === true
            }]
        };
    }
}
