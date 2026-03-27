import QtQuick
import QtQuick.Layouts

import "./Tabs" as SettingsTabs
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsState
    property real preferredWidth: 720 * Style.uiScaleRatio

    spacing: 0
    width: parent ? parent.width : implicitWidth
    implicitWidth: preferredWidth

    NTabBar {
        id: tabBar

        Layout.fillWidth: true
        Layout.bottomMargin: Style.marginM
        distributeEvenly: true
        currentIndex: tabView.currentIndex

        NTabButton {
            text: {
                root.settingsState.translationVersion;
                return root.settingsState.tr("settings.tabs.general", "General");
            }
            tabIndex: 0
            checked: tabBar.currentIndex === 0
        }

        NTabButton {
            text: {
                root.settingsState.translationVersion;
                return root.settingsState.tr("settings.tabs.appearance", "Appearance");
            }
            tabIndex: 1
            checked: tabBar.currentIndex === 1
        }

        NTabButton {
            text: {
                root.settingsState.translationVersion;
                return root.settingsState.tr("settings.tabs.keybinds", "Keybinds");
            }
            tabIndex: 2
            checked: tabBar.currentIndex === 2
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Style.marginL
    }

    NTabView {
        id: tabView

        Layout.fillWidth: true
        currentIndex: tabBar.currentIndex

        SettingsTabs.GeneralTab {
            settingsState: root.settingsState
        }

        SettingsTabs.AppearanceTab {
            settingsState: root.settingsState
        }

        SettingsTabs.KeybindsTab {
            settingsState: root.settingsState
        }
    }
}
