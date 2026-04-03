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
            return root.settingsStore.tr("settings.general.title", "General");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.intro", "Grouped app switcher overlay for Alt-Tab style navigation. Global hotkeys and custom actions stay outside the core plugin and are wired through Hyprland or scripts.");
        }
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
    }

    SettingsSections.GeneralBehaviorSection {
        settingsStore: root.settingsStore
        generalForm: root.settingsForm.general
    }
}
