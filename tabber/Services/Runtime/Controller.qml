import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.Commons
import qs.Services.Compositor
import qs.Services.UI

QtObject {
    id: root

    required property var pluginApi
    required property var settingsState
    required property var session
    required property var groupModel
    required property var actionRegistry

    readonly property int cycleDebounceMs: 70

    function initialize() {
        groupModel.refresh(true);
        groupModel.updateRecentsFromFocusedWindow();
    }

    function handleActiveWindowChanged() {
        groupModel.updateRecentsFromFocusedWindow();
        if (!groupModel.refresh(true) && session.overlayVisible) {
            hideOverlay(false);
        }
    }

    function handleWindowListChanged() {
        if (!groupModel.refresh(true) && session.overlayVisible) {
            hideOverlay(false);
        }
    }

    function isModifierRelease(event) {
        return event.key === Qt.Key_Alt || event.key === Qt.Key_Meta;
    }

    function hideOverlay(resetModifier) {
        session.markHidden(resetModifier);
    }

    function acceptSelection() {
        if (!session.selectedGroup || !session.selectedGroup.primaryWindowId) {
            hideOverlay(false);
            return;
        }

        var hiddenRestoreScript = pluginApi ? (pluginApi.pluginDir + "/scripts/hide-selected-group.sh") : "";
        var selectedWindow = groupModel.findWindowById(session.selectedGroup.primaryWindowId);
        var hiddenWindows = [];
        if (session.selectedGroup.windows) {
            for (var hiddenIndex = 0; hiddenIndex < session.selectedGroup.windows.length; hiddenIndex++) {
                var candidateWindow = session.selectedGroup.windows[hiddenIndex];
                if (candidateWindow && candidateWindow.isHidden === true) {
                    hiddenWindows.push(candidateWindow);
                }
            }
        }

        for (var restoreIndex = 0; restoreIndex < hiddenWindows.length; restoreIndex++) {
            var restoreWindow = hiddenWindows[restoreIndex];
            if (restoreWindow.id === session.selectedGroup.primaryWindowId) {
                continue;
            }
            if (hiddenRestoreScript) {
                Quickshell.execDetached([hiddenRestoreScript, "restore-by-address", String(restoreWindow.id)]);
            }
        }

        if (groupModel.isHiddenWindowId(session.selectedGroup.primaryWindowId)) {
            if (hiddenRestoreScript) {
                Quickshell.execDetached([hiddenRestoreScript, "restore-by-address", String(session.selectedGroup.primaryWindowId)]);
            }
        } else if (selectedWindow) {
            if (settingsState.groupWindowsByApp && session.selectedGroup.windows && session.selectedGroup.windows.length > 1 && Hyprland && Hyprland.dispatch) {
                for (var i = 0; i < session.selectedGroup.windows.length; i++) {
                    var groupedWindow = session.selectedGroup.windows[i];
                    var groupedWindowId = String(groupedWindow.id || "");
                    if (!groupedWindowId || groupedWindow.isHidden === true) {
                        continue;
                    }

                    var groupedWindowAddress = groupedWindowId.indexOf("0x") === 0 ? groupedWindowId : ("0x" + groupedWindowId);
                    Hyprland.dispatch("alterzorder top,address:" + groupedWindowAddress);
                }
            }

            CompositorService.focusWindow(selectedWindow);
        }

        if (!groupModel.isHiddenWindowId(session.selectedGroup.primaryWindowId) && hiddenWindows.length > 0 && selectedWindow) {
            Qt.callLater(function () {
                var refreshedWindow = groupModel.findWindowById(session.selectedGroup.primaryWindowId);
                if (refreshedWindow) {
                    CompositorService.focusWindow(refreshedWindow);
                }
            });
        }

        session.markAccepted();
        hideOverlay(false);
    }

    function runActionDefinition(actionDefinition) {
        if (!actionDefinition || !actionDefinition.script) {
            return;
        }

        Quickshell.execDetached([actionDefinition.script, JSON.stringify(actionRegistry.buildGroupPayload(actionDefinition.id, session.selectedGroup))]);
        Qt.callLater(function () {
            if (!groupModel.refresh(true) && session.overlayVisible) {
                hideOverlay(false);
            }
        });
    }

    function runActionById(actionId) {
        var actionDefinition = actionRegistry.findById(actionId);
        if (!actionDefinition) {
            return false;
        }

        runActionDefinition(actionDefinition);
        return true;
    }

    function runActionForWindow(actionId, win) {
        if (actionId === "close") {
            if (win) {
                CompositorService.closeWindow(win);
            }
            return;
        }

        var actionDefinition = actionRegistry.findById(actionId);
        if (!actionDefinition || !actionDefinition.script) {
            return;
        }

        Quickshell.execDetached([actionDefinition.script, JSON.stringify(actionRegistry.buildWindowPayload(actionId, win))]);
    }

    function handleGlobalModifierRelease(key) {
        session.markModifierReleased(key, "modifier-release-global", Date.now());

        if (!session.overlayVisible || !session.modifierHeld) {
            return;
        }

        session.modifierHeld = false;
        acceptSelection();
    }

    function updateActiveModifierPrefix(source) {
        if (source === "global-shortcut-alt") {
            session.activeModifierPrefix = "Alt";
        } else if (source === "global-shortcut-super") {
            session.activeModifierPrefix = "Super";
        }
    }

    function actionFromEvent(event) {
        var keybind = Keybinds.getKeybindString(event);
        var matchedAction = actionRegistry.findByKeybind(keybind);
        if (matchedAction || !session.modifierHeld || !session.activeModifierPrefix || keybind === "") {
            return matchedAction;
        }

        if (keybind.indexOf(session.activeModifierPrefix + "+") === 0) {
            return null;
        }

        var fallbackKeybind = session.activeModifierPrefix + "+" + keybind;
        return actionRegistry.findByKeybind(fallbackKeybind);
    }

    function trigger(direction, source) {
        if (!pluginApi || !pluginApi.withCurrentScreen) {
            return;
        }

        var now = Date.now();
        var normalizedDirection = direction === "previous" ? "previous" : "next";

        if (session.lastCycleDirection === normalizedDirection && (now - session.lastCycleAt) < cycleDebounceMs) {
            return;
        }

        session.markTriggered(normalizedDirection, source, now);
        updateActiveModifierPrefix(source);

        if (groupModel.groupList.length === 0) {
            if (!groupModel.refresh(false)) {
                return;
            }
        }

        session.modifierHeld = true;

        pluginApi.withCurrentScreen(function (screen) {
            var screenName = screen && screen.name ? screen.name : "";
            if (!session.overlayVisible) {
                session.markOpened(screenName);
                groupModel.moveSelection(normalizedDirection, true);
            } else {
                session.activeScreenName = screenName;
                session.markCycled();
                groupModel.moveSelection(normalizedDirection, false);
            }
        });
    }

    function handleOverlayKeyPress(event) {
        if (!session.overlayVisible) {
            return false;
        }

        if (event.key === Qt.Key_Tab && session.modifierHeld) {
            trigger(event.modifiers & Qt.ShiftModifier ? "previous" : "next", "window");
            return true;
        }

        if (event.key === Qt.Key_Escape) {
            hideOverlay(false);
            return true;
        }

        var matchedAction = actionFromEvent(event);
        if (matchedAction) {
            runActionDefinition(matchedAction);
            return true;
        }

        return false;
    }

    function handleOverlayKeyRelease(event) {
        if (!session.overlayVisible) {
            return false;
        }

        if (session.modifierHeld && isModifierRelease(event)) {
            session.markModifierReleased(event.key, "modifier-release", Date.now());
            session.modifierHeld = false;
            acceptSelection();
            return true;
        }

        return false;
    }

    function debugState() {
        return session.debugState(groupModel.groupList.length, groupModel.displayGroups.length);
    }
}
