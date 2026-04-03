import QtQuick
import Quickshell.Hyprland

import "../Utils/GroupUtils.js" as GroupUtils
import qs.Services.Compositor

QtObject {
    id: root

    required property var session
    required property var settingsStore
    required property var integrationRegistry

    property var entries: []

    function normalizeWindowId(windowId) {
        var normalizedId = String(windowId || "").trim().toLowerCase();
        if (!normalizedId) {
            return "";
        }

        return normalizedId.indexOf("0x") === 0 ? normalizedId : ("0x" + normalizedId);
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

    function shouldIncludeIntegrationEntry(entry, targetOutputName) {
        if (!targetOutputName) {
            return true;
        }

        var windows = entry && entry.windows ? entry.windows : [];
        if (windows.length > 0) {
            return String(windows[0] && windows[0].output || "").trim() === targetOutputName;
        }

        return false;
    }

    function buildVisibleEntries(targetOutputName, visibleWindowIds) {
        var nextEntries = [];

        for (var i = 0; i < CompositorService.windows.count; i++) {
            var win = CompositorService.windows.get(i);
            if (!shouldIncludeVisibleWindow(win, targetOutputName)) {
                continue;
            }

            var normalizedWindowId = normalizeWindowId(win.id);
            visibleWindowIds[normalizedWindowId] = true;
            var windowDimensions = windowDimensionsFor(win);
            nextEntries.push({
                id: normalizedWindowId,
                title: win.title || win.appId || "Untitled",
                appId: win.appId || "",
                workspaceId: win.workspaceId,
                output: win.output || "",
                isFocused: win.isFocused === true,
                width: windowDimensions.width,
                height: windowDimensions.height,
                isIntegrationEntry: false
            });
        }

        return nextEntries;
    }

    function buildIntegrationEntries(targetOutputName, visibleWindowIds) {
        var nextEntries = [];
        var integrationEntries = integrationRegistry ? (integrationRegistry.entries || []) : [];

        for (var index = 0; index < integrationEntries.length; index++) {
            var integrationEntry = integrationEntries[index];
            if (!integrationEntry || !integrationEntry.id || !shouldIncludeIntegrationEntry(integrationEntry, targetOutputName)) {
                continue;
            }

            var integrationWindowId = normalizeWindowId(integrationEntry.primaryWindowId || integrationEntry.id);
            if (!integrationWindowId || visibleWindowIds[integrationWindowId]) {
                continue;
            }

            nextEntries.push(integrationEntry);
        }

        return nextEntries;
    }

    function refresh() {
        var visibleWindowIds = ({});
        var targetOutputName = activeOutputName();
        var nextEntries = buildVisibleEntries(targetOutputName, visibleWindowIds);
        nextEntries = nextEntries.concat(buildIntegrationEntries(targetOutputName, visibleWindowIds));
        entries = nextEntries;
        return entries.length > 0;
    }

    function activateEntry(entry) {
        if (!entry) {
            return false;
        }

        if (entry.isIntegrationEntry === true) {
            return integrationRegistry ? integrationRegistry.activateEntry(entry) : false;
        }

        return false;
    }
}
