import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property bool enabled: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["preview.enabled"], false)
}
