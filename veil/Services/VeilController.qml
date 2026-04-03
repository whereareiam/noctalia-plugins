import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../Utils/HiddenStateUtils.js" as HiddenStateUtils
import qs.Services.Compositor

QtObject {
    id: root

    required property var pluginApi
    required property var hiddenWindowsModel
    required property var stateStore

    readonly property string hiddenWorkspaceName: "special:hidden"
    property var publishedTargets: []

    function initialize() {
        Qt.callLater(pruneStaleWindows);
    }

    function normalizedAddress(address) {
        return HiddenStateUtils.normalizeAddress(address);
    }

    function getFocusedVisibleWindow() {
        for (var index = 0; index < CompositorService.windows.count; index++) {
            var candidate = CompositorService.windows.get(index);
            if (candidate && candidate.isFocused === true && candidate.id) {
                return candidate;
            }
        }

        return null;
    }

    function normalizeProviderId(providerId) {
        return String(providerId || "").trim();
    }

    function publishedTargetEntries() {
        var entries = [];
        var targets = Array.isArray(publishedTargets) ? publishedTargets : [];
        for (var index = 0; index < targets.length; index++) {
            var target = targets[index];
            var providerId = normalizeProviderId(target && target.providerId);
            var normalizedWindowId = normalizedAddress(target && target.windowId);
            if (!providerId || !normalizedWindowId) {
                continue;
            }

            entries.push({
                providerId: providerId,
                priority: Number(target && target.priority || 0),
                windowId: normalizedWindowId,
                groupId: String(target && target.groupId || ""),
                metadata: target && target.metadata ? target.metadata : ({}),
                updatedAt: Number(target && target.updatedAt || 0)
            });
        }

        entries.sort(function (left, right) {
            var priorityDifference = Number(right.priority || 0) - Number(left.priority || 0);
            if (priorityDifference !== 0) {
                return priorityDifference;
            }

            return Number(right.updatedAt || 0) - Number(left.updatedAt || 0);
        });

        return entries;
    }

    function preferredPublishedTarget() {
        var entries = publishedTargetEntries();
        return entries.length > 0 ? entries[0] : null;
    }

    function publishTarget(providerId, priority, windowId, groupId, metadataJson) {
        var normalizedProviderId = normalizeProviderId(providerId);
        var normalizedWindowId = normalizedAddress(windowId);
        if (!normalizedProviderId || !normalizedWindowId) {
            return false;
        }

        var metadata = ({});
        if (metadataJson && String(metadataJson).trim() !== "") {
            try {
                var parsedMetadata = JSON.parse(metadataJson);
                if (parsedMetadata && typeof parsedMetadata === "object") {
                    metadata = parsedMetadata;
                }
            } catch (e) {
            }
        }

        var nextTargets = publishedTargetEntries().filter(function (entry) {
            return entry.providerId !== normalizedProviderId;
        });
        nextTargets.push({
            providerId: normalizedProviderId,
            priority: Number(priority || 0),
            windowId: normalizedWindowId,
            groupId: String(groupId || ""),
            metadata: metadata,
            updatedAt: Date.now()
        });
        publishedTargets = nextTargets;
        return true;
    }

    function clearTarget(providerId) {
        var normalizedProviderId = normalizeProviderId(providerId);
        if (!normalizedProviderId) {
            return false;
        }

        var currentTargets = publishedTargetEntries();
        var hadTarget = currentTargets.some(function (entry) {
            return entry.providerId === normalizedProviderId;
        });
        if (!hadTarget) {
            return false;
        }

        var nextTargets = currentTargets.filter(function (entry) {
            return entry.providerId !== normalizedProviderId;
        });
        publishedTargets = nextTargets;
        return true;
    }

    function selectedWindowAddress() {
        var target = preferredPublishedTarget();
        return normalizedAddress(target && target.windowId);
    }

    function findVisibleWindowByAddress(address) {
        var normalized = normalizedAddress(address);
        if (!normalized) {
            return null;
        }

        for (var index = 0; index < CompositorService.windows.count; index++) {
            var candidate = CompositorService.windows.get(index);
            if (!candidate || !candidate.id) {
                continue;
            }

            if (normalizedAddress(candidate.id) === normalized) {
                return candidate;
            }
        }

        return null;
    }

    function findToplevelByAddress(address) {
        var normalized = normalizedAddress(address);
        if (!normalized || !Hyprland.toplevels || !Hyprland.toplevels.values) {
            return null;
        }

        for (var index = 0; index < Hyprland.toplevels.values.length; index++) {
            var toplevel = Hyprland.toplevels.values[index];
            if (toplevel && normalizedAddress(toplevel.address) === normalized) {
                return toplevel;
            }
        }

        return null;
    }

    function isHiddenToplevel(toplevel) {
        if (!toplevel) {
            return false;
        }

        try {
            if (String(toplevel.workspace && toplevel.workspace.name || "") === hiddenWorkspaceName) {
                return true;
            }
        } catch (e) {
        }

        try {
            var ipcData = toplevel.lastIpcObject;
            if (ipcData && (ipcData.hidden === true || String(ipcData.workspace && ipcData.workspace.name || "") === hiddenWorkspaceName)) {
                return true;
            }
        } catch (e2) {
        }

        return false;
    }

    function workspaceNameFor(win, toplevel) {
        if (toplevel) {
            try {
                var toplevelWorkspace = String(toplevel.workspace && toplevel.workspace.name || "");
                if (toplevelWorkspace) {
                    return toplevelWorkspace;
                }
            } catch (e) {
            }

            try {
                var ipcData = toplevel.lastIpcObject;
                var ipcWorkspace = String(ipcData && ipcData.workspace && ipcData.workspace.name || "");
                if (ipcWorkspace) {
                    return ipcWorkspace;
                }
            } catch (e2) {
            }
        }

        return String(win && win.workspaceId || "");
    }

    function outputNameFor(win, toplevel) {
        var outputName = String(win && win.output || "");
        if (outputName) {
            return outputName;
        }

        if (toplevel) {
            try {
                outputName = String(toplevel.output && toplevel.output.name || toplevel.output || "");
                if (outputName) {
                    return outputName;
                }
            } catch (e) {
            }

            try {
                var ipcData = toplevel.lastIpcObject;
                outputName = String(ipcData && (ipcData.monitorName || ipcData.output || "") || "");
                if (outputName) {
                    return outputName;
                }
            } catch (e2) {
            }
        }

        return "";
    }

    function buildHiddenEntryForWindow(win) {
        if (!win || !win.id) {
            return null;
        }

        var normalized = normalizedAddress(win.id);
        var toplevel = findToplevelByAddress(normalized);
        if (isHiddenToplevel(toplevel)) {
            return null;
        }

        var appId = String(win.appId || toplevel && toplevel.appId || "").trim();
        var title = String(win.title || toplevel && toplevel.title || "").trim();
        if (!appId && !title) {
            return null;
        }

        return {
            address: normalized,
            appId: appId,
            title: title || appId || "Hidden window",
            workspace: workspaceNameFor(win, toplevel),
            output: outputNameFor(win, toplevel),
            hiddenAt: Date.now()
        };
    }

    function dispatchHide(address) {
        var normalized = normalizedAddress(address);
        if (!normalized) {
            return;
        }

        Quickshell.execDetached([
            "sh",
            "-c",
            "hyprctl dispatch movetoworkspacesilent '" + hiddenWorkspaceName + ",address:" + normalized + "' >/dev/null 2>&1 || true"
        ]);
    }

    function dispatchRestore(address) {
        var normalized = normalizedAddress(address);
        if (!normalized) {
            return;
        }

        Quickshell.execDetached([
            "bash",
            "-lc",
            "workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.name // empty'); workspace=${workspace:-1}; "
                + "hyprctl dispatch movetoworkspacesilent \"$workspace,address:" + normalized + "\" >/dev/null 2>&1 || true; "
                + "sleep 0.05; "
                + "hyprctl dispatch focuswindow 'address:" + normalized + "' >/dev/null 2>&1 || true; "
                + "hyprctl dispatch alterzorder 'top,address:" + normalized + "' >/dev/null 2>&1 || true"
        ]);
    }

    function hideWindow(address) {
        var visibleWindow = findVisibleWindowByAddress(address);
        if (!visibleWindow) {
            return false;
        }

        var hiddenEntry = buildHiddenEntryForWindow(visibleWindow);
        if (!hiddenEntry) {
            return false;
        }

        hiddenWindowsModel.upsertWindow(hiddenEntry);
        stateStore.save();
        dispatchHide(hiddenEntry.address);
        return true;
    }

    function restoreWindow(address) {
        var normalized = normalizedAddress(address);
        if (!normalized) {
            return false;
        }

        hiddenWindowsModel.removeWindow(normalized);
        stateStore.save();
        dispatchRestore(normalized);
        return true;
    }

    function toggleWindow(address) {
        var normalized = normalizedAddress(address);
        if (!normalized) {
            return false;
        }

        var visibleWindow = findVisibleWindowByAddress(normalized);
        if (visibleWindow) {
            return hideWindow(visibleWindow.id);
        }

        if (hiddenWindowsModel && hiddenWindowsModel.containsAddress && hiddenWindowsModel.containsAddress(normalized)) {
            return restoreWindow(normalized);
        }

        var hiddenToplevel = findToplevelByAddress(normalized);
        if (isHiddenToplevel(hiddenToplevel)) {
            return restoreWindow(normalized);
        }

        return false;
    }

    function toggleFocused() {
        var selectedAddress = selectedWindowAddress();
        if (selectedAddress) {
            return toggleWindow(selectedAddress);
        }

        var focusedWindow = getFocusedVisibleWindow();
        if (!focusedWindow) {
            return false;
        }

        return toggleWindow(focusedWindow.id);
    }

    function openRestoreMenu() {
        if (!pluginApi || !pluginApi.withCurrentScreen) {
            return false;
        }

        pluginApi.withCurrentScreen(function (screen) {
            pluginApi.openPanel(screen);
        });
        return true;
    }

    function pruneStaleWindows() {
        var nextWindows = hiddenWindowsModel.windows.filter(function (entry) {
            var toplevel = findToplevelByAddress(entry && entry.address);
            return toplevel && isHiddenToplevel(toplevel);
        });

        if (nextWindows.length !== hiddenWindowsModel.windows.length) {
            hiddenWindowsModel.setWindows(nextWindows);
            stateStore.save();
        }
    }

    function list() {
        return HiddenStateUtils.stateJson(hiddenWindowsModel.windows);
    }

    function debugState() {
        return JSON.stringify({
            hiddenCount: hiddenWindowsModel.hiddenCount,
            loaded: stateStore.loaded,
            statePath: stateStore.statePath,
            publishedTargets: publishedTargetEntries()
        });
    }
}
