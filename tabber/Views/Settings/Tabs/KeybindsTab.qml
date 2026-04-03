import QtQuick
import QtQuick.Layouts

import "../Sections" as SettingsSections
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var settingsForm

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.keybinds.title", "Keybinds");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    SettingsSections.KeybindHelpSection {
        settingsStore: root.settingsStore
    }

    NDivider {
        Layout.fillWidth: true
    }

    SettingsSections.ActionsSection {
        settingsStore: root.settingsStore
        actionsForm: root.settingsForm.actions
    }
}
