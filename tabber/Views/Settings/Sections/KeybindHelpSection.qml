import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

NBox {
    id: root

    required property var settingsStore

    Layout.fillWidth: true
    implicitHeight: keybindHelpColumn.implicitHeight + Style.marginL * 2
    color: Color.mSurfaceVariant
    forceOpaque: true

    ColumnLayout {
        id: keybindHelpColumn

        anchors.fill: parent
        anchors.margins: Style.marginL
        spacing: Style.marginS

        NText {
            Layout.fillWidth: true
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.help.title", "Tabber hotkeys are set in your Hyprland config, not here in the plugin settings.");
            }
            pointSize: Style.fontSizeS
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
            wrapMode: Text.WordWrap
        }

        NText {
            Layout.fillWidth: true
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.help.description", "Choose any Hyprland keybinds you want and point them at the Tabber global actions, then reload Hyprland.");
            }
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
        }

        NText {
            Layout.fillWidth: true
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.help.examplesLabel", "Example Hyprland bindings:");
            }
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
        }

        NText {
            Layout.fillWidth: true
            font.family: Settings.data.ui.fontFixed
            pointSize: Style.fontSizeXS
            color: Color.mOnSurface
            wrapMode: Text.WrapAnywhere
            text: "bind = ALT, Tab, global, tabber:select-next\n"
                + "bind = ALT SHIFT, Tab, global, tabber:select-previous\n"
                + "bind = ALT, Grave, global, tabber:enter-group\n"
                + "bind = , Alt_L, global, tabber:release-alt-left\n"
                + "bind = , Alt_R, global, tabber:release-alt-right"
        }

        NText {
            Layout.fillWidth: true
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.help.actionsNote", "Actions are defined by ID and script. Overlay shortcuts are optional and only apply while Tabber is open.");
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }
}
