import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property int cardSize: SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.selection.cardSize", "cardSize"], 108)
    readonly property int cardGap: SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.selection.cardGap", "cardGap"], 9)
    readonly property int iconSize: SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.selection.iconSize", "iconSize"], 64)
    readonly property string titleVisibility: SettingsUtils.settingString(settingsStore.pluginApi, settingsStore.defaults, ["appearance.selection.titleVisibility", "titleVisibility"], "selected")
    readonly property string titleTruncationMode: SettingsUtils.settingString(settingsStore.pluginApi, settingsStore.defaults, ["appearance.selection.titleTruncationMode", "titleTruncationMode"], "end")
}
