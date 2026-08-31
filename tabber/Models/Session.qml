import QtQuick

QtObject {
    id: root

    property bool overlayVisible: false
    property bool modifierHeld: false
    property string activeModifierPrefix: ""
    property string activeScreenName: ""
    property string selectedGroupId: ""
    property var selectedGroup: null
    property bool windowSelectionActive: false
    property string windowSelectionGroupId: ""
    property string selectedWindowId: ""
    property var selectedWindow: null
    property double lastCycleAt: 0
    property string lastCycleDirection: ""
    property double lastTriggerAt: 0
    property string lastTriggerSource: ""
    property string lastTriggerDirection: ""
    property double lastModifierReleaseAt: 0
    property int lastModifierReleaseKey: 0
    property string lastLifecycleEvent: "idle"

    function markTriggered(direction, source, at) {
        lastCycleDirection = direction;
        lastCycleAt = at;
        lastTriggerAt = at;
        lastTriggerSource = String(source || "");
        lastTriggerDirection = direction;
        lastLifecycleEvent = "trigger";
    }

    function markOpened(screenName) {
        overlayVisible = true;
        activeScreenName = screenName;
        lastLifecycleEvent = "opened";
    }

    function markCycled() {
        lastLifecycleEvent = "cycled";
    }

    function markAccepted() {
        lastLifecycleEvent = "accepted";
    }

    function markHidden(resetModifier) {
        overlayVisible = false;
        lastLifecycleEvent = "hidden";
        activeModifierPrefix = "";
        windowSelectionActive = false;
        windowSelectionGroupId = "";
        selectedWindowId = "";
        selectedWindow = null;
        if (resetModifier !== false) {
            modifierHeld = false;
        }
    }

    function markModifierReleased(key, lifecycleEvent, at) {
        lastModifierReleaseAt = at;
        lastModifierReleaseKey = key;
        lastLifecycleEvent = lifecycleEvent || "modifier-release";
    }

    function debugState(groupCount, displayGroupCount) {
        return JSON.stringify({
            overlayVisible: overlayVisible,
            modifierHeld: modifierHeld,
            activeScreenName: activeScreenName,
            selectedGroupId: selectedGroupId,
            windowSelectionActive: windowSelectionActive,
            windowSelectionGroupId: windowSelectionGroupId,
            selectedWindowId: selectedWindowId,
            groupCount: groupCount,
            displayGroupCount: displayGroupCount,
            lastTriggerAt: lastTriggerAt,
            lastTriggerSource: lastTriggerSource,
            lastTriggerDirection: lastTriggerDirection,
            lastModifierReleaseAt: lastModifierReleaseAt,
            lastModifierReleaseKey: lastModifierReleaseKey,
            lastLifecycleEvent: lastLifecycleEvent
        });
    }
}
