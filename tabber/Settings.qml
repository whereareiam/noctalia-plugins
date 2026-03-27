import QtQuick
import QtQuick.Layouts

import "./Models/Settings" as SettingsModels
import "./Views/Settings" as SettingsViews
import qs.Commons

ColumnLayout {
    id: root

    property var pluginApi: null
    property real preferredWidth: 720 * Style.uiScaleRatio

    width: parent ? parent.width : implicitWidth
    implicitWidth: preferredWidth

    function saveSettings() {
        settingsState.saveSettings();
    }

    SettingsModels.SettingsState {
        id: settingsState

        pluginApi: root.pluginApi
    }

    SettingsViews.SettingsView {
        Layout.fillWidth: true
        settingsState: settingsState
        preferredWidth: root.preferredWidth
    }
}
