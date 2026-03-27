import QtQuick
import QtQuick.Layouts

import "../../Utils/ActionUtils.js" as ActionUtils
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsState
    property var actionData: ({})
    property int actionIndex: -1
    property bool showSeparator: false

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginM

    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginXS
        Layout.bottomMargin: Style.marginXS
        radius: Style.radiusM
        color: Qt.alpha(Color.mSurfaceVariant, 0.85)
        border.color: Qt.alpha(Color.mOutline, 0.7)
        border.width: Style.borderS
        implicitHeight: entryColumn.implicitHeight + Style.margin2M

        ColumnLayout {
            id: entryColumn

            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                NText {
                    text: {
                        return ActionUtils.tabberActionDisplayName(root.actionData, root.actionIndex);
                    }
                    pointSize: Style.fontSizeS
                    font.weight: Style.fontWeightBold
                    color: Color.mOnSurface
                }

                Item {
                    Layout.fillWidth: true
                }

                NIconButton {
                    icon: "trash"
                    tooltipText: {
                        root.settingsState.translationVersion;
                        return root.settingsState.tr("settings.keybinds.actionEntry.removeTooltip", "Remove action");
                    }
                    colorBg: "transparent"
                    colorBgHover: Qt.alpha(Color.mError, 0.12)
                    colorFg: Color.mOnSurfaceVariant
                    colorFgHover: Color.mError
                    border.width: 0
                    onClicked: root.settingsState.removeAction(root.actionIndex)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginL

                NText {
                    Layout.preferredWidth: Math.round(92 * Style.uiScaleRatio)
                    Layout.alignment: Qt.AlignVCenter
                    text: {
                        root.settingsState.translationVersion;
                        return root.settingsState.tr("settings.keybinds.actionEntry.keybindLabel", "Keybind");
                    }
                    pointSize: Style.fontSizeL
                    font.weight: Style.fontWeightSemiBold
                    color: Color.mOnSurface
                }

                Item {
                    Layout.fillWidth: true
                }

                NKeybindRecorder {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: Math.round(180 * Style.uiScaleRatio)
                    Layout.maximumWidth: Math.round(180 * Style.uiScaleRatio)
                    maxKeybinds: 1
                    allowEmpty: true
                    currentKeybinds: root.actionData.keybind ? [root.actionData.keybind] : []
                    onKeybindsChanged: newKeybinds => root.settingsState.updateActionKeybind(root.actionIndex, newKeybinds)
                }
            }

            NTextInput {
                Layout.fillWidth: true
                label: {
                    root.settingsState.translationVersion;
                    return root.settingsState.tr("settings.keybinds.actionEntry.scriptLabel", "Script");
                }
                text: root.actionData.script || ""
                onTextChanged: root.settingsState.updateActionField(root.actionIndex, "script", text)
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        visible: root.showSeparator
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
        Layout.preferredHeight: 1
        implicitHeight: 1
        radius: 1
        color: Qt.alpha(Color.mOutline, 0.65)
    }
}
