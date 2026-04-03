import QtQuick
import QtQuick.Layouts

import "." as SettingsComponents
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var actionsForm

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NText {
            text: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.actions.title", "Actions");
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
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.keybinds.actions.add", "Add action");
            }
            icon: "plus"
            onClicked: root.actionsForm.addAction()
        }
    }

    Repeater {
        model: root.actionsForm.items

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
                    Layout.fillWidth: true
                    settingsStore: root.settingsStore
                    actionForm: root.actionsForm
                    actionData: modelData
                    actionIndex: index
                    showSeparator: index < (root.actionsForm.items.length - 1)
                }
            }
        }
    }
}
