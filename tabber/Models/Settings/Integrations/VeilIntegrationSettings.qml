import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property bool enabled: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["integrations.veil.enabled"], true)
    readonly property bool highlightHiddenCards: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["integrations.veil.highlightHiddenCards"], true)
    readonly property string hiddenCardAccentColor: SettingsUtils.settingString(settingsStore.pluginApi, settingsStore.defaults, ["integrations.veil.hiddenCardAccentColor"], "")
}
