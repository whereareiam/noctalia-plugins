import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property bool groupWindowsByApp: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.groupWindowsByApp", "groupWindowsByApp"], true)
    readonly property bool enterGroupedWindowSelection: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.enterGroupedWindowSelection", "enterGroupedWindowSelection"], false)
    readonly property bool restrictToCurrentMonitor: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.restrictToCurrentMonitor", "restrictToCurrentMonitor"], false)
    readonly property bool requirePointerMovementForHoverSelection: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["general.requirePointerMovementForHoverSelection", "requirePointerMovementForHoverSelection"], true)
}
