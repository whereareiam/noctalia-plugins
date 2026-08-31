import QtQuick

import "../Utils/GroupUtils.js" as GroupUtils

QtObject {
    id: root

    required property var session
    required property var groupModel

    property var displayGroups: []
    readonly property string displaySelectedId: session.windowSelectionActive ? session.selectedWindowId : session.selectedGroupId

    function nextIndexForMove(currentIndex, itemCount, direction, wrapAround) {
        if (itemCount <= 0) {
            return -1;
        }

        var normalizedCurrentIndex = currentIndex;
        if (normalizedCurrentIndex < 0 || normalizedCurrentIndex >= itemCount) {
            normalizedCurrentIndex = 0;
        }

        var step = direction === "previous" ? -1 : 1;
        var candidateIndex = normalizedCurrentIndex + step;
        if (wrapAround === false && (candidateIndex < 0 || candidateIndex >= itemCount)) {
            return -1;
        }

        return (candidateIndex + itemCount) % itemCount;
    }

    function syncSelection(keepSelection) {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            session.selectedGroupId = "";
            session.selectedGroup = null;
            clearWindowSelection();
            displayGroups = [];
            return false;
        }

        if (!keepSelection || !session.selectedGroupId) {
            session.selectedGroupId = groups[0].groupId;
        } else {
            var stillExists = groups.some(function (group) {
                return group.groupId === session.selectedGroupId;
            });
            if (!stillExists) {
                session.selectedGroupId = groups[0].groupId;
            }
        }

        syncSelectedGroup();
        if (session.windowSelectionActive) {
            syncWindowSelection();
        }
        updateDisplayGroups();
        return true;
    }

    function syncSelectedGroup() {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            session.selectedGroup = null;
            return;
        }

        var matchedGroup = null;
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].groupId === session.selectedGroupId) {
                matchedGroup = groups[i];
                break;
            }
        }

        session.selectedGroup = matchedGroup || groups[0] || null;
    }

    function clearWindowSelection() {
        session.windowSelectionActive = false;
        session.windowSelectionGroupId = "";
        session.selectedWindowId = "";
        session.selectedWindow = null;
    }

    function displayDataForWindow(windowData, groupData) {
        var title = String(windowData && windowData.title || windowData && windowData.appId || "Untitled");
        return {
            groupId: String(windowData && windowData.id || ""),
            appId: String(windowData && windowData.appId || groupData && groupData.appId || ""),
            iconSource: groupData ? groupData.iconSource : "",
            primaryWindowId: String(windowData && windowData.id || ""),
            primaryTitle: title,
            windowCount: 1,
            windows: windowData ? [windowData] : [],
            hasFocusedWindow: windowData && windowData.isFocused === true,
            selectionCardHighlighted: groupData && groupData.selectionCardHighlighted === true,
            selectionCardAccentColor: groupData ? groupData.selectionCardAccentColor : "",
            isIntegrationEntry: false,
            integrationId: "",
            integrationAction: null
        };
    }

    function selectedGroupWindows() {
        if (!session.selectedGroup || !session.selectedGroup.windows) {
            return [];
        }

        return session.selectedGroup.windows.slice();
    }

    function syncWindowSelection() {
        if (!session.windowSelectionActive || !session.selectedGroup || session.selectedGroup.groupId !== session.windowSelectionGroupId) {
            clearWindowSelection();
            return false;
        }

        var windows = selectedGroupWindows();
        if (windows.length <= 1) {
            clearWindowSelection();
            return false;
        }

        var preferredWindow = GroupUtils.choosePreferredWindow(windows, session.selectedWindowId || session.selectedGroup.primaryWindowId);
        if (!preferredWindow) {
            clearWindowSelection();
            return false;
        }

        session.selectedWindowId = String(preferredWindow.id || "");
        session.selectedWindow = preferredWindow;
        return true;
    }

    function updateDisplayGroups() {
        syncSelectedGroup();

        if (session.windowSelectionActive && syncWindowSelection()) {
            var windows = selectedGroupWindows();
            displayGroups = windows.map(function (windowData) {
                return displayDataForWindow(windowData, session.selectedGroup);
            });
            return;
        }

        displayGroups = groupModel && groupModel.groupList ? groupModel.groupList.slice() : [];
    }

    function selectGroup(groupId) {
        if (!groupId) {
            return;
        }

        clearWindowSelection();
        session.selectedGroupId = groupId;
        updateDisplayGroups();
    }

    function enterWindowSelection() {
        if (!session.selectedGroup || !session.selectedGroup.windows || session.selectedGroup.windows.length <= 1) {
            return false;
        }

        session.windowSelectionActive = true;
        session.windowSelectionGroupId = session.selectedGroup.groupId;
        session.selectedWindowId = session.selectedGroup.primaryWindowId || "";
        if (!syncWindowSelection()) {
            return false;
        }

        updateDisplayGroups();
        return true;
    }

    function exitWindowSelection() {
        if (!session.windowSelectionActive) {
            return false;
        }

        clearWindowSelection();
        updateDisplayGroups();
        return true;
    }

    function selectWindow(windowId) {
        if (!session.windowSelectionActive || !windowId) {
            return;
        }

        session.selectedWindowId = String(windowId || "");
        syncWindowSelection();
        updateDisplayGroups();
    }

    function selectDisplayItem(itemId) {
        if (session.windowSelectionActive) {
            selectWindow(itemId);
        } else {
            selectGroup(itemId);
        }
    }

    function moveSelection(direction, forceFromFocused, wrapAround) {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            return false;
        }

        var orderedIds = groups.map(function (group) {
            return group.groupId;
        });
        var anchorId = forceFromFocused ? groupModel.getCurrentFocusedGroupId() : session.selectedGroupId;
        var currentIndex = orderedIds.indexOf(anchorId);
        if (currentIndex < 0) {
            currentIndex = 0;
        }

        var nextIndex = nextIndexForMove(currentIndex, orderedIds.length, direction, wrapAround);
        if (nextIndex < 0 || orderedIds[nextIndex] === session.selectedGroupId) {
            return false;
        }

        session.selectedGroupId = orderedIds[nextIndex];
        updateDisplayGroups();
        return true;
    }

    function moveWindowSelection(direction, wrapAround) {
        var windows = selectedGroupWindows();
        if (!session.windowSelectionActive || windows.length === 0) {
            return false;
        }

        var orderedIds = windows.map(function (windowData) {
            return String(windowData && windowData.id || "");
        }).filter(function (windowId) {
            return windowId !== "";
        });
        if (orderedIds.length === 0) {
            return false;
        }

        var currentIndex = orderedIds.indexOf(session.selectedWindowId);
        if (currentIndex < 0) {
            currentIndex = 0;
        }

        var nextIndex = nextIndexForMove(currentIndex, orderedIds.length, direction, wrapAround);
        if (nextIndex < 0 || orderedIds[nextIndex] === session.selectedWindowId) {
            return false;
        }

        session.selectedWindowId = orderedIds[nextIndex];
        syncWindowSelection();
        updateDisplayGroups();
        return true;
    }
}
