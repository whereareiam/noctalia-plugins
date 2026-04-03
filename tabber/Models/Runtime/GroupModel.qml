import QtQuick

import "../../Utils/GroupUtils.js" as GroupUtils
import qs.Commons
import qs.Services.UI

QtObject {
    id: root

    required property var session
    required property var settingsStore
    property var sourceEntries: []

    property var groupList: []
    property var recentGroupIds: []
    property var lastFocusedWindowByGroup: ({})

    function groupIdForEntry(entry) {
        if (!entry) {
            return "";
        }

        if (entry.groupId) {
            return String(entry.groupId);
        }

        if (settingsStore && settingsStore.general.groupWindowsByApp === false) {
            return "window-" + GroupUtils.normalizeGroupId(entry.id);
        }

        return GroupUtils.normalizeGroupId(entry.appId || entry.title || entry.id);
    }

    function getFocusedEntry() {
        for (var i = 0; i < sourceEntries.length; i++) {
            var candidate = sourceEntries[i];
            if (candidate && candidate.isFocused === true && candidate.isHidden !== true) {
                return candidate;
            }
        }
        return null;
    }

    function getCurrentFocusedGroupId() {
        var focusedEntry = getFocusedEntry();
        return focusedEntry ? groupIdForEntry(focusedEntry) : "";
    }

    function updateRecentsFromFocusedWindow() {
        var focusedEntry = getFocusedEntry();
        if (!focusedEntry) {
            return;
        }

        var groupId = groupIdForEntry(focusedEntry);
        var nextGroups = recentGroupIds.filter(function (id) {
            return id !== groupId;
        });
        nextGroups.unshift(groupId);
        recentGroupIds = nextGroups;

        var updatedLastFocused = Object.assign({}, lastFocusedWindowByGroup);
        updatedLastFocused[groupId] = focusedEntry.id;
        lastFocusedWindowByGroup = updatedLastFocused;
    }

    function buildGroups() {
        var groupsById = ({});
        var seenIds = [];

        for (var i = 0; i < sourceEntries.length; i++) {
            var entry = sourceEntries[i];
            if (!entry || !entry.id) {
                continue;
            }

            var groupId = groupIdForEntry(entry);
            if (!groupsById[groupId]) {
                groupsById[groupId] = {
                    groupId: groupId,
                    appId: entry.appId || "",
                    iconSource: entry.iconSource || ThemeIcons.iconForAppId(entry.appId || ""),
                    windows: [],
                    hasFocusedWindow: false,
                    hasVisibleWindow: false,
                    selectionCardHighlighted: entry.selectionCardHighlighted === true,
                    selectionCardAccentColor: entry.selectionCardAccentColor || "",
                    isIntegrationEntry: entry.isIntegrationEntry === true,
                    integrationId: entry.integrationId || "",
                    integrationAction: entry.integrationAction || ""
                };
                seenIds.push(groupId);
            }

            groupsById[groupId].windows.push({
                id: entry.id,
                title: entry.title || entry.appId || "Untitled",
                appId: entry.appId || "",
                workspaceId: entry.workspaceId || "",
                output: entry.output || "",
                isFocused: entry.isFocused === true,
                width: Number(entry.width || 0),
                height: Number(entry.height || 0),
                isHidden: entry.isHidden === true
            });

            if (entry.isFocused) {
                groupsById[groupId].hasFocusedWindow = true;
            }
            if (entry.isHidden !== true) {
                groupsById[groupId].hasVisibleWindow = true;
            }

            if (settingsStore && settingsStore.general.groupWindowsByApp === false) {
                groupsById[groupId].primaryWindowId = entry.id;
                groupsById[groupId].primaryTitle = entry.title || entry.appId || "Untitled";
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
                    hasFocusedWindow: group.hasFocusedWindow,
                    selectionCardHighlighted: group.selectionCardHighlighted,
                    selectionCardAccentColor: group.selectionCardAccentColor,
                    isIntegrationEntry: group.isIntegrationEntry,
                    integrationId: group.integrationId,
                    integrationAction: group.integrationAction
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
                hasFocusedWindow: group.hasFocusedWindow,
                selectionCardHighlighted: group.selectionCardHighlighted,
                selectionCardAccentColor: group.selectionCardAccentColor,
                isIntegrationEntry: group.isIntegrationEntry,
                integrationId: group.integrationId,
                integrationAction: group.integrationAction
            };
        });
    }

    function refresh() {
        groupList = buildGroups();
        return groupList.length > 0;
    }
}
