import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var generalForm

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.groupByApp.label", "Group windows by app");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.groupByApp.description", "When enabled, multiple windows from the same app appear as one item. Disable it for normal per-window switching.");
        }
        checked: root.generalForm.groupWindowsByApp
        onToggled: checked => root.generalForm.groupWindowsByApp = checked
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.currentMonitorOnly.label", "Current monitor only");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.currentMonitorOnly.description", "When enabled, Tabber only shows windows from the monitor where the overlay was opened.");
        }
        checked: root.generalForm.restrictToCurrentMonitor
        onToggled: checked => root.generalForm.restrictToCurrentMonitor = checked
    }
}
