import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property bool groupWindowsByApp: settings ? settings.groupWindowsByApp : true
    property bool restrictToCurrentMonitor: settings ? settings.restrictToCurrentMonitor : false

    function reset() {
        groupWindowsByApp = settings.groupWindowsByApp;
        restrictToCurrentMonitor = settings.restrictToCurrentMonitor;
    }

    function persist(target) {
        SettingsUtils.clearPaths(target, ["groupWindowsByApp", "restrictToCurrentMonitor", "showHiddenWindows", "triggerKeybind", "reverseTriggerKeybind"]);
        SettingsUtils.setPathValue(target, "general.groupWindowsByApp", groupWindowsByApp);
        SettingsUtils.setPathValue(target, "general.restrictToCurrentMonitor", restrictToCurrentMonitor);
    }
}
