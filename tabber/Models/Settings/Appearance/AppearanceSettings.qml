import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property real dimOpacity: SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.dimOpacity", "dimOpacity"], 0.36)
    readonly property QtObject container: AppearanceContainerSettings {
        settingsStore: root.settingsStore
    }
    readonly property QtObject header: AppearanceHeaderSettings {
        settingsStore: root.settingsStore
    }
    readonly property QtObject selection: AppearanceSelectionSettings {
        settingsStore: root.settingsStore
    }
}
