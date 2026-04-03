import QtQuick

QtObject {
    id: root

    required property var session
    required property var groupModel

    property var displayGroups: []

    function syncSelection(keepSelection) {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            session.selectedGroupId = "";
            session.selectedGroup = null;
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

        updateDisplayGroups();
        return true;
    }

    function updateDisplayGroups() {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            displayGroups = [];
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

        displayGroups = groups.slice();
        session.selectedGroup = matchedGroup || displayGroups[0] || null;
    }

    function selectGroup(groupId) {
        if (!groupId) {
            return;
        }

        session.selectedGroupId = groupId;
        updateDisplayGroups();
    }

    function moveSelection(direction, forceFromFocused) {
        var groups = groupModel ? groupModel.groupList : [];
        if (!groups || groups.length === 0) {
            return;
        }

        var orderedIds = groups.map(function (group) {
            return group.groupId;
        });
        var anchorId = forceFromFocused ? groupModel.getCurrentFocusedGroupId() : session.selectedGroupId;
        var currentIndex = orderedIds.indexOf(anchorId);
        if (currentIndex < 0) {
            currentIndex = 0;
        }

        var step = direction === "previous" ? -1 : 1;
        var nextIndex = (currentIndex + step + orderedIds.length) % orderedIds.length;
        session.selectedGroupId = orderedIds[nextIndex];
        updateDisplayGroups();
    }
}
