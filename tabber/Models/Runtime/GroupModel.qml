import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "../../Utils/GroupUtils.js" as GroupUtils
import qs.Commons
import qs.Services.Compositor
import qs.Services.UI

QtObject {
    id: root

    required property var session
    required property var settingsState

    property var groupList: []
    property var displayGroups: []
    property var hiddenEntries: []
    property var recentGroupIds: []
    property var lastFocusedWindowByGroup: ({})

    readonly property string hiddenStatePath: {
        var runtimeDir = Quickshell.env("XDG_RUNTIME_DIR");
        var uid = Quickshell.env("UID");
        if (!runtimeDir && uid) {
            runtimeDir = "/run/user/" + uid;
        }
        return runtimeDir ? (runtimeDir + "/hypr-hidden-window/hidden-windows.json") : "";
    }

    function getFocusedWindow() {
        for (var i = 0; i < CompositorService.windows.count; i++) {
            var candidate = CompositorService.windows.get(i);
            if (candidate && candidate.isFocused) {
                return candidate;
            }
        }
        return null;
    }

    function getCurrentFocusedGroupId() {
        var focused = getFocusedWindow();
        return focused ? groupIdForWindow(focused) : "";
    }

    function reloadHiddenEntries() {
        if (!hiddenStateView.path) {
            hiddenEntries = [];
            return;
        }

        try {
            var parsed = JSON.parse(hiddenStateView.text());
            hiddenEntries = Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            hiddenEntries = [];
        }
    }

    function groupIdForWindow(win) {
        if (!win) {
            return "";
        }

        if (settingsState && settingsState.groupWindowsByApp === false) {
            return "window-" + GroupUtils.normalizeGroupId(win.id);
        }

        return GroupUtils.normalizeGroupId(win.appId || win.title || win.id);
    }

    function groupIdForHiddenEntry(entry) {
        if (!entry) {
            return "";
        }

        if (settingsState && settingsState.groupWindowsByApp === false) {
            return "window-" + GroupUtils.normalizeGroupId(entry.address);
        }

        return GroupUtils.normalizeGroupId(entry.app_id || entry.title || entry.address);
    }

    function findWindowById(windowId) {
        for (var i = 0; i < CompositorService.windows.count; i++) {
            var win = CompositorService.windows.get(i);
            if (win && win.id === windowId) {
                return win;
            }
        }
        return null;
    }

    function hiddenEntryById(windowId) {
        var targetId = String(windowId || "");
        for (var i = 0; i < hiddenEntries.length; i++) {
            if (String(hiddenEntries[i].address || "") === targetId) {
                return hiddenEntries[i];
            }
        }
        return null;
    }

    function isHiddenWindowId(windowId) {
        return !!hiddenEntryById(windowId);
    }

    function findHyprlandToplevel(windowId) {
        if (!windowId || !Hyprland.toplevels || !Hyprland.toplevels.values) {
            return null;
        }

        for (var i = 0; i < Hyprland.toplevels.values.length; i++) {
            var toplevel = Hyprland.toplevels.values[i];
            if (toplevel && String(toplevel.address || "") === String(windowId)) {
                return toplevel;
            }
        }

        return null;
    }

    function isSwitchableWindow(win) {
        if (!win || !win.id) {
            return false;
        }

        var appId = String(win.appId || "").trim();
        var title = String(win.title || "").trim();
        if (!appId && !title) {
            return false;
        }

        if (GroupUtils.isSpecialWorkspaceId(win.workspaceId)) {
            return false;
        }

        var toplevel = findHyprlandToplevel(win.id);
        if (!toplevel) {
            return true;
        }

        try {
            if (toplevel.workspace && GroupUtils.isSpecialWorkspaceId(toplevel.workspace.id)) {
                return false;
            }
        } catch (e) {
        }

        try {
            var ipcData = toplevel.lastIpcObject;
            if (ipcData) {
                if (ipcData.hidden === true || ipcData.mapped === false) {
                    return false;
                }
                if (ipcData.workspace && GroupUtils.isSpecialWorkspaceId(ipcData.workspace.id)) {
                    return false;
                }
            }
        } catch (e2) {
        }

        return true;
    }

    function updateRecentsFromFocusedWindow() {
        var focused = getFocusedWindow();
        if (!focused || !isSwitchableWindow(focused)) {
            return;
        }

        var groupId = groupIdForWindow(focused);
        var nextGroups = recentGroupIds.filter(function (id) {
            return id !== groupId;
        });
        nextGroups.unshift(groupId);
        recentGroupIds = nextGroups;

        var updatedLastFocused = Object.assign({}, lastFocusedWindowByGroup);
        updatedLastFocused[groupId] = focused.id;
        lastFocusedWindowByGroup = updatedLastFocused;
    }

    function buildGroups() {
        var groupsById = ({});
        var seenIds = [];
        var visibleWindowIds = ({});

        for (var i = 0; i < CompositorService.windows.count; i++) {
            var win = CompositorService.windows.get(i);
            if (!isSwitchableWindow(win)) {
                continue;
            }

            visibleWindowIds[String(win.id || "")] = true;

            var groupId = groupIdForWindow(win);
            if (!groupsById[groupId]) {
                groupsById[groupId] = {
                    groupId: groupId,
                    appId: win.appId || "",
                    iconSource: ThemeIcons.iconForAppId(win.appId || ""),
                    windows: [],
                    hasFocusedWindow: false
                };
                seenIds.push(groupId);
            }

            groupsById[groupId].windows.push({
                id: win.id,
                title: win.title || win.appId || "Untitled",
                appId: win.appId || "",
                workspaceId: win.workspaceId,
                output: win.output || "",
                isFocused: win.isFocused === true
            });

            if (win.isFocused) {
                groupsById[groupId].hasFocusedWindow = true;
            }

            if (settingsState && settingsState.groupWindowsByApp === false) {
                groupsById[groupId].primaryWindowId = win.id;
                groupsById[groupId].primaryTitle = win.title || win.appId || "Untitled";
            }
        }

        for (var hiddenIndex = 0; hiddenIndex < hiddenEntries.length; hiddenIndex++) {
            if (!settingsState || settingsState.showHiddenWindows !== true) {
                break;
            }

            var hiddenEntry = hiddenEntries[hiddenIndex];
            var hiddenId = String(hiddenEntry && hiddenEntry.address || "");
            if (!hiddenId || visibleWindowIds[hiddenId]) {
                continue;
            }

            var hiddenGroupId = groupIdForHiddenEntry(hiddenEntry);
            if (!groupsById[hiddenGroupId]) {
                groupsById[hiddenGroupId] = {
                    groupId: hiddenGroupId,
                    appId: hiddenEntry.app_id || "",
                    iconSource: ThemeIcons.iconForAppId(hiddenEntry.app_id || ""),
                    windows: [],
                    hasFocusedWindow: false
                };
                seenIds.push(hiddenGroupId);
            }

            groupsById[hiddenGroupId].windows.push({
                id: hiddenId,
                title: hiddenEntry.title || hiddenEntry.app_id || "Hidden window",
                appId: hiddenEntry.app_id || "",
                workspaceId: hiddenEntry.workspace || "",
                output: "",
                isFocused: false,
                isHidden: true
            });

            if (settingsState && settingsState.groupWindowsByApp === false) {
                groupsById[hiddenGroupId].primaryWindowId = hiddenId;
                groupsById[hiddenGroupId].primaryTitle = hiddenEntry.title || hiddenEntry.app_id || "Hidden window";
            }
        }

        var orderedIds = [];
        for (var recentIndex = 0; recentIndex < recentGroupIds.length; recentIndex++) {
            if (groupsById[recentGroupIds[recentIndex]]) {
                orderedIds.push(recentGroupIds[recentIndex]);
            }
        }

        for (var seenIndex = 0; seenIndex < seenIds.length; seenIndex++) {
            if (orderedIds.indexOf(seenIds[seenIndex]) === -1) {
                orderedIds.push(seenIds[seenIndex]);
            }
        }

        return orderedIds.map(function (groupId) {
            var group = groupsById[groupId];
            if (settingsState && settingsState.groupWindowsByApp === false) {
                return {
                    groupId: group.groupId,
                    appId: group.appId,
                    iconSource: group.iconSource,
                    primaryWindowId: group.primaryWindowId || "",
                    primaryTitle: group.primaryTitle || (group.appId || "Unknown app"),
                    windowCount: group.windows.length,
                    windows: group.windows,
                    hasFocusedWindow: group.hasFocusedWindow
                };
            }

            var preferredWindowId = lastFocusedWindowByGroup[groupId];
            var preferredWindow = GroupUtils.choosePreferredWindow(group.windows, preferredWindowId);

            return {
                groupId: group.groupId,
                appId: group.appId,
                iconSource: group.iconSource,
                primaryWindowId: preferredWindow ? preferredWindow.id : "",
                primaryTitle: preferredWindow ? preferredWindow.title : (group.appId || "Unknown app"),
                windowCount: group.windows.length,
                windows: group.windows,
                hasFocusedWindow: group.hasFocusedWindow
            };
        });
    }

    function refresh(keepSelection) {
        groupList = buildGroups();

        if (groupList.length === 0) {
            session.selectedGroupId = "";
            session.selectedGroup = null;
            displayGroups = [];
            return false;
        }

        if (!keepSelection || !session.selectedGroupId) {
            session.selectedGroupId = groupList[0].groupId;
        } else {
            var stillExists = groupList.some(function (group) {
                return group.groupId === session.selectedGroupId;
            });
            if (!stillExists) {
                session.selectedGroupId = groupList[0].groupId;
            }
        }

        updateDisplayGroups();
        return true;
    }

    function updateDisplayGroups() {
        if (groupList.length === 0) {
            displayGroups = [];
            session.selectedGroup = null;
            return;
        }

        var matchedGroup = null;
        for (var i = 0; i < groupList.length; i++) {
            if (groupList[i].groupId === session.selectedGroupId) {
                matchedGroup = groupList[i];
                break;
            }
        }

        displayGroups = groupList.slice();
        session.selectedGroup = matchedGroup || displayGroups[0] || null;
    }

    function moveSelection(direction, forceFromFocused) {
        if (groupList.length === 0) {
            return;
        }

        var orderedIds = groupList.map(function (group) {
            return group.groupId;
        });
        var anchorId = forceFromFocused ? getCurrentFocusedGroupId() : session.selectedGroupId;
        var currentIndex = orderedIds.indexOf(anchorId);
        if (currentIndex < 0) {
            currentIndex = 0;
        }

        var step = direction === "previous" ? -1 : 1;
        var nextIndex = (currentIndex + step + orderedIds.length) % orderedIds.length;
        session.selectedGroupId = orderedIds[nextIndex];
        updateDisplayGroups();
    }

  property FileView hiddenStateView: FileView {
    id: hiddenStateView

    path: root.hiddenStatePath || undefined
    printErrors: false
    watchChanges: true

        onLoaded: {
            root.reloadHiddenEntries();
            root.refresh(true);
        }

        onFileChanged: reload()

        onLoadFailed: {
            root.hiddenEntries = [];
            root.refresh(true);
        }
    }
}
