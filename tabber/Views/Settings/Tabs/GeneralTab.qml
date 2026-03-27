import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsState

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.title", "General");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.intro", "Grouped app switcher overlay for Alt-Tab style navigation. The Hyprland side is already wired to the bundled Tabber trigger/action scripts.");
        }
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.groupByApp.label", "Group windows by app");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.groupByApp.description", "When enabled, multiple windows from the same app appear as one item. Disable it for normal per-window switching.");
        }
        checked: root.settingsState.editGroupWindowsByApp
        onToggled: checked => root.settingsState.editGroupWindowsByApp = checked
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.showHidden.label", "Show hidden windows");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.general.showHidden.description", "When enabled, hidden windows stay visible in Tabber and selecting them restores them from hidden.");
        }
        checked: root.settingsState.editShowHiddenWindows
        onToggled: checked => root.settingsState.editShowHiddenWindows = checked
    }

}
