import QtQuick
import QtQuick.Layouts

import "../Sections" as SettingsSections
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var settingsForm
    required property var veilPluginState

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.integrations.title", "Integrations");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.integrations.intro", "Configure optional integrations with other plugins. Integrations are only active when the target plugin is installed and enabled.");
        }
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
    }

    SettingsSections.VeilIntegrationSection {
        settingsStore: root.settingsStore
        veilIntegrationForm: root.settingsForm.integrations.veil
        veilPluginState: root.veilPluginState
    }
}
