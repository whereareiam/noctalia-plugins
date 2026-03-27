import QtQuick
import QtQuick.Layouts

import "../../../Components/Settings" as SettingsComponents
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
            return root.settingsState.tr("settings.keybinds.title", "Keybinds");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NBox {
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
                    root.settingsState.translationVersion;
                    return root.settingsState.tr("settings.keybinds.hyprNoticeTitle", "Tabber hotkeys are set in your Hyprland config, not here in the plugin settings.");
                }
                pointSize: Style.fontSizeS
                font.weight: Style.fontWeightBold
                color: Color.mOnSurface
                wrapMode: Text.WordWrap
            }

            NText {
                Layout.fillWidth: true
                text: {
                    root.settingsState.translationVersion;
                    return root.settingsState.tr("settings.keybinds.hyprNoticeDescription", "Choose any Hyprland keybinds you want and point them at the Tabber global actions, then reload Hyprland.");
                }
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
            }

            NText {
                Layout.fillWidth: true
                text: {
                    root.settingsState.translationVersion;
                    return root.settingsState.tr("settings.keybinds.currentLinesLabel", "Example Hyprland bindings:");
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
                    + "bind = , Alt_L, global, tabber:release-alt-left\n"
                    + "bind = , Alt_R, global, tabber:release-alt-right"
            }

            NText {
                Layout.fillWidth: true
                text: {
                    root.settingsState.translationVersion;
                    return root.settingsState.tr("settings.keybinds.actionsNote", "The action bindings below still belong to Tabber itself.");
                }
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }
    }

    NDivider {
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NText {
            text: {
                root.settingsState.translationVersion;
                return root.settingsState.tr("settings.keybinds.actionsTitle", "Actions");
            }
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
        }

        Item {
            Layout.fillWidth: true
        }

        NButton {
            text: {
                root.settingsState.translationVersion;
                return root.settingsState.tr("settings.keybinds.addAction", "Add action");
            }
            icon: "plus"
            onClicked: root.settingsState.addAction()
        }
    }

    Repeater {
        model: root.settingsState.editActions

        delegate: Item {
            required property var modelData
            required property int index

            Layout.fillWidth: true
            width: parent ? parent.width : root.width
            implicitHeight: actionColumn.implicitHeight

            ColumnLayout {
                id: actionColumn

                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Style.marginM

                SettingsComponents.ActionEntry {
                    id: actionEntry

                    Layout.fillWidth: true
                    settingsState: root.settingsState
                    actionData: modelData
                    actionIndex: index
                    showSeparator: index < (root.settingsState.editActions.length - 1)
                }
            }
        }
    }
}
