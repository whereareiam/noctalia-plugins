import QtQuick
import QtQuick.Layouts

import "./Tabs" as SettingsTabs
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var settingsForm
    required property var veilPluginState
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
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.tabs.general", "General");
            }
            tabIndex: 0
            checked: tabBar.currentIndex === 0
        }

        NTabButton {
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.tabs.appearance", "Appearance");
            }
            tabIndex: 1
            checked: tabBar.currentIndex === 1
        }

        NTabButton {
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.tabs.keybinds", "Keybinds");
            }
            tabIndex: 2
            checked: tabBar.currentIndex === 2
        }

        NTabButton {
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.tabs.integrations", "Integrations");
            }
            tabIndex: 3
            checked: tabBar.currentIndex === 3
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
            settingsStore: root.settingsStore
            settingsForm: root.settingsForm
        }

        SettingsTabs.AppearanceTab {
            settingsStore: root.settingsStore
            settingsForm: root.settingsForm
        }

        SettingsTabs.KeybindsTab {
            settingsStore: root.settingsStore
            settingsForm: root.settingsForm
        }

        SettingsTabs.IntegrationsTab {
            settingsStore: root.settingsStore
            settingsForm: root.settingsForm
            veilPluginState: root.veilPluginState
        }
    }
}
