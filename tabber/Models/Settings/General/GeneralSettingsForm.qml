import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property bool groupWindowsByApp: settings ? settings.groupWindowsByApp : true
    property bool enterGroupedWindowSelection: settings ? settings.enterGroupedWindowSelection : false
    property bool restrictToCurrentMonitor: settings ? settings.restrictToCurrentMonitor : false
    property bool requirePointerMovementForHoverSelection: settings ? settings.requirePointerMovementForHoverSelection : true
    property bool cycleSelectionWhileHoldingTab: settings ? settings.cycleSelectionWhileHoldingTab : false
    property bool stopContinuousCycleAtEdge: settings ? settings.stopContinuousCycleAtEdge : false

    function reset() {
        groupWindowsByApp = settings.groupWindowsByApp;
        enterGroupedWindowSelection = settings.enterGroupedWindowSelection;
        restrictToCurrentMonitor = settings.restrictToCurrentMonitor;
        requirePointerMovementForHoverSelection = settings.requirePointerMovementForHoverSelection;
        cycleSelectionWhileHoldingTab = settings.cycleSelectionWhileHoldingTab;
        stopContinuousCycleAtEdge = settings.stopContinuousCycleAtEdge;
    }

    function persist(target) {
        SettingsUtils.clearPaths(target, ["groupWindowsByApp", "enterGroupedWindowSelection", "restrictToCurrentMonitor", "requirePointerMovementForHoverSelection", "cycleSelectionWhileHoldingTab", "stopContinuousCycleAtEdge", "showHiddenWindows", "triggerKeybind", "reverseTriggerKeybind"]);
        SettingsUtils.setPathValue(target, "general.groupWindowsByApp", groupWindowsByApp);
        SettingsUtils.setPathValue(target, "general.enterGroupedWindowSelection", groupWindowsByApp && enterGroupedWindowSelection);
        SettingsUtils.setPathValue(target, "general.restrictToCurrentMonitor", restrictToCurrentMonitor);
        SettingsUtils.setPathValue(target, "general.requirePointerMovementForHoverSelection", requirePointerMovementForHoverSelection);
        SettingsUtils.setPathValue(target, "general.cycleSelectionWhileHoldingTab", cycleSelectionWhileHoldingTab);
        SettingsUtils.setPathValue(target, "general.stopContinuousCycleAtEdge", cycleSelectionWhileHoldingTab && stopContinuousCycleAtEdge);
    }
}
