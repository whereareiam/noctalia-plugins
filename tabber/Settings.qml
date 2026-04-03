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
        settingsForm.saveSettings();
    }

    SettingsModels.SettingsStore {
        id: settingsStore

        pluginApi: root.pluginApi
    }

    SettingsModels.SettingsForm {
        id: settingsForm

        settingsStore: settingsStore
    }

    SettingsViews.SettingsView {
        Layout.fillWidth: true
        settingsStore: settingsStore
        settingsForm: settingsForm
        preferredWidth: root.preferredWidth
    }
}
