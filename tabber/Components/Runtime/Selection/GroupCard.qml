import QtQuick
import Quickshell.Widgets

import qs.Commons
import qs.Widgets

MouseArea {
    id: root

    required property var groupData
    property bool selected: false
    property int cardSize: 108
    property int iconSizeValue: 64

        signal
    hoverSelected
        signal
    activateSelected

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    readonly property int tileSize: Math.round((cardSize + 28) * Style.uiScaleRatio)
    readonly property int iconSize: Math.max(
                                        Math.round(24 * Style.uiScaleRatio),
                                        Math.min(
                                            Math.round(root.iconSizeValue * Style.uiScaleRatio),
                                            tileSize - Math.round(Style.marginS * 4)))

    width: tileSize
    height: tileSize

    onEntered: {
        if (!selected) {
            hoverSelected();
        }
    }

    onClicked: activateSelected()

    Rectangle {
        anchors.fill: parent
        radius: Style.radiusM
        color: root.selected ? Color.mPrimary : Qt.alpha(Color.mSurface, 0.9)
        border.color: root.selected ? Qt.alpha(Color.mOnPrimary, 0.65) : Qt.alpha(Color.mOutline, root.containsMouse ? 0.8 : 0.45)
        border.width: root.selected ? Style.borderM : Style.borderS

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
            }
        }

        Behavior on border
        .
        color {
            ColorAnimation {
                duration: Style.animationFast
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: Style.marginS

            IconImage {
                anchors.centerIn: parent
                width: root.iconSize
                height: width
                source: root.groupData.iconSource
                smooth: true
                asynchronous: true
            }

            Rectangle {
                visible: root.groupData.windowCount > 1
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: Math.round(24 * Style.uiScaleRatio)
                height: width
                radius: width / 2
                color: root.selected ? Qt.alpha(Color.mOnPrimary, 0.18) : Qt.alpha(Color.mPrimary, 0.18)
                border.color: root.selected ? Qt.alpha(Color.mOnPrimary, 0.35) : Qt.alpha(Color.mPrimary, 0.35)
                border.width: Style.borderS

                NText {
                    anchors.centerIn: parent
                    text: root.groupData.windowCount
                    pointSize: Style.fontSizeS
                    font.weight: Style.fontWeightBold
                    color: root.selected ? Color.mOnPrimary : Color.mPrimary
                }
            }
        }
    }
}
