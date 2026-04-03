import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property bool groupWindowsByApp: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.groupWindowsByApp", "groupWindowsByApp"], true)
    readonly property bool restrictToCurrentMonitor: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.restrictToCurrentMonitor", "restrictToCurrentMonitor"], false)
}
