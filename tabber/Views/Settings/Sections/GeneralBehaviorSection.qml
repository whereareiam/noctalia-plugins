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
        visible: root.generalForm.groupWindowsByApp
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.enterGroupedWindowSelection.label", "Enter grouped windows");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.enterGroupedWindowSelection.description", "When enabled, the enter-group keybind opens the selected app group so you can choose the exact window to focus.");
        }
        checked: root.generalForm.enterGroupedWindowSelection
        onToggled: checked => root.generalForm.enterGroupedWindowSelection = checked
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

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.requirePointerMovementForHoverSelection.label", "Require pointer movement for hover selection");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.general.behavior.requirePointerMovementForHoverSelection.description", "When enabled, a stationary mouse cannot change the initial Tabber selection. Hover only starts affecting selection after the pointer moves.");
        }
        checked: root.generalForm.requirePointerMovementForHoverSelection
        onToggled: checked => root.generalForm.requirePointerMovementForHoverSelection = checked
    }
}
