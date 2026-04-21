import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs.Commons
import qs.Services.Compositor
import qs.Services.UI

QtObject {
    id: root

    required property var pluginApi
    required property var settingsStore
    required property var session
    required property var windowCatalog
    required property var integrationRegistry
    required property var groupModel
    required property var selectionModel
    required property var actionRegistry

    readonly property int cycleDebounceMs: 70

    function initialize() {
        syncGroupModelWithFocus();
        publishSelectionContext();
    }

    function refreshGroups(keepSelection) {
        windowCatalog.refresh();
        groupModel.refresh();
        return selectionModel.syncSelection(keepSelection);
    }

    function syncGroupModelWithFocus() {
        if (!refreshGroups(true)) {
            if (session.overlayVisible) {
                hideOverlay(false);
            }
            return false;
        }

        groupModel.updateRecentsFromFocusedWindow();

        if (!refreshGroups(true)) {
            if (session.overlayVisible) {
                hideOverlay(false);
            }
            return false;
        }

        return true;
    }

    function handleActiveWindowChanged() {
        syncGroupModelWithFocus();
    }

    function handleWindowListChanged() {
        syncGroupModelWithFocus();
    }

    function isModifierRelease(event) {
        return event.key === Qt.Key_Alt || event.key === Qt.Key_Meta;
    }

    function hideOverlay(resetModifier) {
        session.markHidden(resetModifier);
        publishSelectionContext();
    }

    function groupedWindowArea(windowData) {
        if (!windowData) {
            return 0;
        }

        var width = Number(windowData.width || 0);
        var height = Number(windowData.height || 0);
        if (!Number.isFinite(width) || width < 0) {
            width = 0;
        }
        if (!Number.isFinite(height) || height < 0) {
            height = 0;
        }

        return width * height;
    }

    function sortedGroupedWindows(windows) {
        var orderedWindows = Array.isArray(windows) ? windows.slice() : [];
        orderedWindows.sort(function (leftWindow, rightWindow) {
            var areaDifference = groupedWindowArea(rightWindow) - groupedWindowArea(leftWindow);
            if (areaDifference !== 0) {
                return areaDifference;
            }

            var leftTitle = String(leftWindow && leftWindow.title || "");
            var rightTitle = String(rightWindow && rightWindow.title || "");
            if (leftTitle !== rightTitle) {
                return leftTitle.localeCompare(rightTitle);
            }

            return String(leftWindow && leftWindow.id || "").localeCompare(String(rightWindow && rightWindow.id || ""));
        });
        return orderedWindows;
    }

    function frontWindowIdForGroupedSelection(groupData) {
        var orderedWindows = sortedGroupedWindows(groupData && groupData.windows ? groupData.windows : []);
        return orderedWindows.length > 0 ? orderedWindows[orderedWindows.length - 1].id : (groupData ? groupData.primaryWindowId : "");
    }

    function restackGroupedSelection(groupData, frontWindowId) {
        if (!Hyprland || !Hyprland.dispatch) {
            return;
        }

        var orderedWindows = sortedGroupedWindows(groupData && groupData.windows ? groupData.windows : []);
        for (var index = 0; index < orderedWindows.length; index++) {
            var groupedWindow = orderedWindows[index];
            if (!groupedWindow || !groupedWindow.id) {
                continue;
            }

            var groupedWindowId = String(groupedWindow.id || "");
            var groupedWindowAddress = groupedWindowId.indexOf("0x") === 0 ? groupedWindowId : ("0x" + groupedWindowId);
            Hyprland.dispatch("alterzorder top,address:" + groupedWindowAddress);
        }

        focusWindowById(frontWindowId);
    }

    function focusWindowById(windowId) {
        var normalizedWindowId = String(windowId || "");
        if (!normalizedWindowId) {
            return;
        }

        var windowAddress = normalizedWindowId.indexOf("0x") === 0 ? normalizedWindowId : ("0x" + normalizedWindowId);
        Quickshell.execDetached(["bash", "-lc", "sleep 0.08; hyprctl dispatch focuswindow 'address:" + windowAddress + "' >/dev/null 2>&1 || true; hyprctl dispatch alterzorder 'top,address:" + windowAddress + "' >/dev/null 2>&1 || true"]);

        var targetWindow = windowCatalog.findWindowById(windowId);
        if (targetWindow) {
            CompositorService.focusWindow(targetWindow);
        }
    }

    function acceptSelection() {
        if (session.windowSelectionActive) {
            acceptWindowSelection();
            return;
        }

        if (!session.selectedGroup || !session.selectedGroup.primaryWindowId) {
            hideOverlay(false);
            return;
        }

        var groupedSelection = settingsStore.general.groupWindowsByApp && session.selectedGroup.windows && session.selectedGroup.windows.length > 1;
        var targetWindowId = groupedSelection ? frontWindowIdForGroupedSelection(session.selectedGroup) : session.selectedGroup.primaryWindowId;

        session.markAccepted();
        hideOverlay(false);

        Qt.callLater(function () {
            if (session.selectedGroup.isIntegrationEntry === true) {
                activateIntegrationEntry(session.selectedGroup);
                Qt.callLater(function () {
                    refreshGroups(true);
                    focusWindowById(targetWindowId);
                });
                return;
            }

            if (groupedSelection) {
                restackGroupedSelection(session.selectedGroup, targetWindowId);
            } else {
                focusWindowById(targetWindowId);
            }
        });
    }

    function acceptWindowSelection() {
        var targetWindowId = String(session.selectedWindowId || "");
        var targetWindow = session.selectedWindow;
        if (!targetWindowId && targetWindow) {
            targetWindowId = String(targetWindow.id || "");
        }

        session.markAccepted();
        hideOverlay(false);

        if (!targetWindowId) {
            return;
        }

        Qt.callLater(function () {
            focusWindowById(targetWindowId);
        });
    }

    function canEnterSelectedGroup() {
        return session.overlayVisible
            && settingsStore
            && settingsStore.general
            && settingsStore.general.groupWindowsByApp === true
            && settingsStore.general.enterGroupedWindowSelection === true
            && session.selectedGroup
            && session.selectedGroup.isIntegrationEntry !== true
            && session.selectedGroup.windows
            && session.selectedGroup.windows.length > 1;
    }

    function enterSelectedGroup() {
        if (session.windowSelectionActive) {
            return true;
        }

        if (!canEnterSelectedGroup()) {
            return false;
        }

        return selectionModel.enterWindowSelection();
    }

    function enterGroupDiagnostic() {
        var selectedGroup = session ? session.selectedGroup : null;
        return {
            overlayVisible: session ? session.overlayVisible === true : false,
            windowSelectionActive: session ? session.windowSelectionActive === true : false,
            groupWindowsByApp: settingsStore && settingsStore.general ? settingsStore.general.groupWindowsByApp === true : false,
            enterGroupedWindowSelection: settingsStore && settingsStore.general ? settingsStore.general.enterGroupedWindowSelection === true : false,
            selectedGroupId: selectedGroup ? String(selectedGroup.groupId || "") : "",
            selectedGroupTitle: selectedGroup ? String(selectedGroup.primaryTitle || "") : "",
            selectedGroupWindowCount: selectedGroup && selectedGroup.windows ? selectedGroup.windows.length : 0,
            selectedGroupIsIntegrationEntry: selectedGroup ? selectedGroup.isIntegrationEntry === true : false,
            displayGroupCount: selectionModel && selectionModel.displayGroups ? selectionModel.displayGroups.length : 0,
            canEnter: canEnterSelectedGroup()
        };
    }

    function groupDebugList() {
        var groups = groupModel && groupModel.groupList ? groupModel.groupList : [];
        return groups.map(function (group) {
            return {
                groupId: String(group && group.groupId || ""),
                title: String(group && group.primaryTitle || ""),
                appId: String(group && group.appId || ""),
                windowCount: group && group.windows ? group.windows.length : 0,
                selected: session && group && group.groupId === session.selectedGroupId
            };
        });
    }

    function enterSelectedGroupDebug() {
        var before = enterGroupDiagnostic();
        var entered = enterSelectedGroup();
        var after = enterGroupDiagnostic();
        return JSON.stringify({
            entered: entered,
            before: before,
            after: after
        });
    }

    function activateIntegrationEntry(groupData) {
        if (!windowCatalog || !groupData || groupData.isIntegrationEntry !== true) {
            return false;
        }

        return windowCatalog.activateEntry(groupData);
    }

    function selectedGroupHasHiddenWindows() {
        if (!session.selectedGroup || !session.selectedGroup.windows) {
            return false;
        }

        for (var index = 0; index < session.selectedGroup.windows.length; index++) {
            if (session.selectedGroup.windows[index] && session.selectedGroup.windows[index].isHidden === true) {
                return true;
            }
        }

        return false;
    }

    function runActionDefinition(actionDefinition) {
        if (!actionDefinition || !actionDefinition.script) {
            return;
        }

        Quickshell.execDetached([actionDefinition.script, JSON.stringify(actionRegistry.buildGroupPayload(actionDefinition.id, session.selectedGroup))]);
        Qt.callLater(function () {
            if (!refreshGroups(true) && session.overlayVisible) {
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
        var actionDefinition = actionRegistry.findById(actionId);
        if (!actionDefinition || !actionDefinition.script) {
            return;
        }

        Quickshell.execDetached([actionDefinition.script, JSON.stringify(actionRegistry.buildWindowPayload(actionId, win))]);
    }

    function targetWindowIdForGroupAction(groupData) {
        if (!groupData) {
            return "";
        }

        if (groupData.isIntegrationEntry === true) {
            return String(groupData.primaryWindowId || "");
        }

        var groupedSelection = settingsStore.general.groupWindowsByApp && groupData.windows && groupData.windows.length > 1;
        return groupedSelection ? frontWindowIdForGroupedSelection(groupData) : String(groupData.primaryWindowId || "");
    }

    function publishSelectionContext() {
        if (!integrationRegistry) {
            return false;
        }

        integrationRegistry.syncSelectionTarget(session ? session.selectedGroup : null, {
            overlayVisible: session ? session.overlayVisible === true : false,
            targetWindowId: targetWindowIdForGroupAction(session ? session.selectedGroup : null)
        });
        return true;
    }

    function integrationActionFromKeybind(keybind) {
        if (!integrationRegistry || !session.selectedGroup) {
            return null;
        }

        var normalizedKeybind = String(keybind || "").trim();
        if (!normalizedKeybind) {
            return null;
        }

        var matchedAction = integrationRegistry.findGroupActionByOverlayKeybind(session.selectedGroup, normalizedKeybind);
        if (matchedAction || !session.modifierHeld || !session.activeModifierPrefix) {
            return matchedAction;
        }

        if (normalizedKeybind.indexOf(session.activeModifierPrefix + "+") === 0) {
            return null;
        }

        return integrationRegistry.findGroupActionByOverlayKeybind(session.selectedGroup, session.activeModifierPrefix + "+" + normalizedKeybind);
    }

    function runIntegrationGroupAction(action, groupData) {
        if (!integrationRegistry || !action || !groupData) {
            return false;
        }

        var actionContext = {
            targetWindowId: targetWindowIdForGroupAction(groupData)
        };
        var didRun = integrationRegistry.runGroupAction(action, groupData, actionContext);
        if (!didRun) {
            return false;
        }

        Qt.callLater(function () {
            if (!refreshGroups(true) && session.overlayVisible) {
                hideOverlay(false);
            }
        });
        return true;
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
        var matchedAction = actionRegistry.findByOverlayKeybind(keybind);
        if (matchedAction || !session.modifierHeld || !session.activeModifierPrefix || keybind === "") {
            return matchedAction;
        }

        if (keybind.indexOf(session.activeModifierPrefix + "+") === 0) {
            return null;
        }

        var fallbackKeybind = session.activeModifierPrefix + "+" + keybind;
        return actionRegistry.findByOverlayKeybind(fallbackKeybind);
    }

    function isEnterGroupKeyEvent(event) {
        if (!event || !((event.modifiers & Qt.AltModifier) || (event.modifiers & Qt.MetaModifier))) {
            return false;
        }

        return event.key === Qt.Key_Dead_Circumflex
            || event.key === Qt.Key_Dead_Grave
            || event.key === Qt.Key_Dead_Tilde
            || event.key === Qt.Key_QuoteLeft
            || event.key === Qt.Key_AsciiCircum
            || event.key === Qt.Key_section
            || event.key === Qt.Key_degree;
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

        if (groupModel.groupList.length === 0 && !refreshGroups(false)) {
            return;
        }

        session.modifierHeld = true;

        pluginApi.withCurrentScreen(function (screen) {
            var screenName = screen && screen.name ? screen.name : "";
            if (!session.overlayVisible) {
                session.markOpened(screenName);
                if (!refreshGroups(false)) {
                    hideOverlay(false);
                    return;
                }
                selectionModel.moveSelection(normalizedDirection, true);
            } else if (session.windowSelectionActive) {
                session.activeScreenName = screenName;
                session.markCycled();
                if (!refreshGroups(true)) {
                    hideOverlay(false);
                    return;
                }
                selectionModel.moveWindowSelection(normalizedDirection);
            } else {
                session.activeScreenName = screenName;
                session.markCycled();
                if (!refreshGroups(true)) {
                    hideOverlay(false);
                    return;
                }
                selectionModel.moveSelection(normalizedDirection, false);
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

        if (isEnterGroupKeyEvent(event) && enterSelectedGroup()) {
            console.log("[Tabber] entered grouped window selection from overlay key");
            return true;
        }

        if (event.key === Qt.Key_Escape) {
            if (session.windowSelectionActive && selectionModel.exitWindowSelection()) {
                return true;
            }

            hideOverlay(false);
            return true;
        }

        var integrationAction = integrationActionFromKeybind(Keybinds.getKeybindString(event));
        if (integrationAction && runIntegrationGroupAction(integrationAction, session.selectedGroup)) {
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
        return JSON.stringify(Object.assign(JSON.parse(session.debugState(groupModel.groupList.length, selectionModel.displayGroups.length)), {
            enterGroup: enterGroupDiagnostic(),
            groups: groupDebugList()
        }));
    }
}
