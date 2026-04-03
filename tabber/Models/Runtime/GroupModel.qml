import QtQuick
import Quickshell.Hyprland

import "../../Utils/GroupUtils.js" as GroupUtils
import qs.Commons
import qs.Services.Compositor
import qs.Services.UI

QtObject {
    id: root

    required property var session
    required property var settingsStore

    property var groupList: []
    property var recentGroupIds: []
    property var lastFocusedWindowByGroup: ({})

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

    function normalizeWindowId(windowId) {
        var normalizedId = String(windowId || "").trim().toLowerCase();
        if (!normalizedId) {
            return "";
        }

        return normalizedId.indexOf("0x") === 0 ? normalizedId : ("0x" + normalizedId);
    }

    function groupIdForWindow(win) {
        if (!win) {
            return "";
        }

        if (settingsStore && settingsStore.general.groupWindowsByApp === false) {
            return "window-" + GroupUtils.normalizeGroupId(win.id);
        }

        return GroupUtils.normalizeGroupId(win.appId || win.title || win.id);
    }

    function findWindowById(windowId) {
        var normalizedWindowId = normalizeWindowId(windowId);
        for (var i = 0; i < CompositorService.windows.count; i++) {
            var win = CompositorService.windows.get(i);
            if (!win) {
                continue;
            }

            if (win.id === windowId || normalizeWindowId(win.id) === normalizedWindowId) {
                return win;
            }
        }
        return null;
    }

    function findHyprlandToplevel(windowId) {
        var normalizedWindowId = normalizeWindowId(windowId);
        if (!normalizedWindowId || !Hyprland.toplevels || !Hyprland.toplevels.values) {
            return null;
        }

        for (var i = 0; i < Hyprland.toplevels.values.length; i++) {
            var toplevel = Hyprland.toplevels.values[i];
            if (toplevel && normalizeWindowId(toplevel.address) === normalizedWindowId) {
                return toplevel;
            }
        }

        return null;
    }

    function dimensionValue(value) {
        var numericValue = Number(value);
        return Number.isFinite(numericValue) && numericValue > 0 ? numericValue : 0;
    }

    function windowDimensionsFor(win) {
        var width = dimensionValue(win ? win.width : 0);
        var height = dimensionValue(win ? win.height : 0);
        if (width > 0 && height > 0) {
            return {
                width: width,
                height: height
            };
        }

        var toplevel = findHyprlandToplevel(win ? win.id : "");
        if (toplevel && toplevel.lastIpcObject && Array.isArray(toplevel.lastIpcObject.size) && toplevel.lastIpcObject.size.length >= 2) {
            width = dimensionValue(toplevel.lastIpcObject.size[0]);
            height = dimensionValue(toplevel.lastIpcObject.size[1]);
        }

        return {
            width: width,
            height: height
        };
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

    function activeOutputName() {
        if (!settingsStore || settingsStore.general.restrictToCurrentMonitor !== true) {
            return "";
        }

        return String(session && session.activeScreenName || "").trim();
    }

    function shouldIncludeVisibleWindow(win, targetOutputName) {
        if (!isSwitchableWindow(win)) {
            return false;
        }

        if (!targetOutputName) {
            return true;
        }

        return String(win && win.output || "").trim() === targetOutputName;
    }

    function buildGroups() {
        var groupsById = ({});
        var seenIds = [];
        var targetOutputName = activeOutputName();

        for (var i = 0; i < CompositorService.windows.count; i++) {
            var win = CompositorService.windows.get(i);
            if (!shouldIncludeVisibleWindow(win, targetOutputName)) {
                continue;
            }

            var windowDimensions = windowDimensionsFor(win);
            var groupId = groupIdForWindow(win);
            if (!groupsById[groupId]) {
                groupsById[groupId] = {
                    groupId: groupId,
                    appId: win.appId || "",
                    iconSource: ThemeIcons.iconForAppId(win.appId || ""),
                    windows: [],
                    hasFocusedWindow: false,
                    hasVisibleWindow: false
                };
                seenIds.push(groupId);
            }

            groupsById[groupId].windows.push({
                id: win.id,
                title: win.title || win.appId || "Untitled",
                appId: win.appId || "",
                workspaceId: win.workspaceId,
                output: win.output || "",
                isFocused: win.isFocused === true,
                width: windowDimensions.width,
                height: windowDimensions.height
            });

            if (win.isFocused) {
                groupsById[groupId].hasFocusedWindow = true;
            }
            groupsById[groupId].hasVisibleWindow = true;

            if (settingsStore && settingsStore.general.groupWindowsByApp === false) {
                groupsById[groupId].primaryWindowId = win.id;
                groupsById[groupId].primaryTitle = win.title || win.appId || "Untitled";
            }
        }

        var orderedVisibleIds = [];
        var orderedHiddenIds = [];
        for (var recentIndex = 0; recentIndex < recentGroupIds.length; recentIndex++) {
            var recentGroupId = recentGroupIds[recentIndex];
            var recentGroup = groupsById[recentGroupId];
            if (!recentGroup) {
                continue;
            }

            if (recentGroup.hasVisibleWindow === true) {
                orderedVisibleIds.push(recentGroupId);
            } else {
                orderedHiddenIds.push(recentGroupId);
            }
        }

        for (var seenIndex = 0; seenIndex < seenIds.length; seenIndex++) {
            var seenGroupId = seenIds[seenIndex];
            var seenGroup = groupsById[seenGroupId];
            if (!seenGroup) {
                continue;
            }

            var targetBucket = seenGroup.hasVisibleWindow === true ? orderedVisibleIds : orderedHiddenIds;
            if (targetBucket.indexOf(seenGroupId) === -1) {
                targetBucket.push(seenGroupId);
            }
        }

        var orderedIds = orderedVisibleIds.concat(orderedHiddenIds);

        return orderedIds.map(function (groupId) {
            var group = groupsById[groupId];
            if (settingsStore && settingsStore.general.groupWindowsByApp === false) {
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

    function refresh() {
        groupList = buildGroups();
        return groupList.length > 0;
    }
}
