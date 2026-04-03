import QtQuick
import Quickshell.Widgets

import "../../../Utils/SettingsUtils.js" as SettingsUtils
import qs.Commons
import qs.Widgets

MouseArea {
    id: root

    required property var groupData
    property bool selected: false
    property int cardSize: 108
    property int iconSizeValue: 64
    property bool hoverSelectionEnabled: true

    signal hoverSelected
    signal activateSelected

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    readonly property int tileSize: Math.round((cardSize + 28) * Style.uiScaleRatio)
    readonly property int iconSize: Math.max(
                                        Math.round(24 * Style.uiScaleRatio),
                                        Math.min(
                                            Math.round(root.iconSizeValue * Style.uiScaleRatio),
                                            tileSize - Math.round(Style.marginS * 4)))
    readonly property bool cardHighlightVisible: root.groupData && root.groupData.selectionCardHighlighted === true
    readonly property string normalizedCardAccentColorValue: String(root.groupData && root.groupData.selectionCardAccentColor || "").trim()
    readonly property color cardAccentColor: SettingsUtils.isHexColorString(root.normalizedCardAccentColorValue)
        ? root.normalizedCardAccentColorValue
        : Color.mPrimary
    readonly property color cardFillColor: root.cardHighlightVisible
        ? Qt.tint(Qt.alpha(Color.mSurface, 0.9), Qt.alpha(root.cardAccentColor, root.selected ? 0.28 : 0.16))
        : (root.selected ? Color.mPrimary : Qt.alpha(Color.mSurface, 0.9))
    readonly property color cardBorderColor: root.cardHighlightVisible
        ? Qt.alpha(root.cardAccentColor, root.selected ? 0.9 : (root.containsMouse ? 0.72 : 0.52))
        : (root.selected ? Qt.alpha(Color.mOnPrimary, 0.65) : Qt.alpha(Color.mOutline, root.containsMouse ? 0.8 : 0.45))
    readonly property color counterAccentColor: root.cardHighlightVisible ? root.cardAccentColor : Color.mPrimary

    width: tileSize
    height: tileSize

    onEntered: {
        if (root.hoverSelectionEnabled && !selected) {
            hoverSelected();
        }
    }

    onPositionChanged: {
        if (root.hoverSelectionEnabled && root.containsMouse && !root.selected) {
            hoverSelected();
        }
    }

    onClicked: activateSelected()

    Rectangle {
        anchors.fill: parent
        radius: Style.radiusM
        color: root.cardFillColor
        border.color: root.cardBorderColor
        border.width: root.selected ? Style.borderM : Style.borderS

        Behavior on color {
            ColorAnimation {
                duration: Style.animationFast
            }
        }

        Behavior on border.color {
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
                color: Qt.alpha(root.counterAccentColor, root.cardHighlightVisible ? (root.selected ? 0.18 : 0.14) : 0.18)
                border.color: Qt.alpha(root.counterAccentColor, root.cardHighlightVisible ? (root.selected ? 0.42 : 0.35) : 0.35)
                border.width: Style.borderS

                NText {
                    anchors.centerIn: parent
                    text: root.groupData.windowCount
                    pointSize: Style.fontSizeS
                    font.weight: Style.fontWeightBold
                    color: root.cardHighlightVisible ? root.counterAccentColor : (root.selected ? Color.mOnPrimary : Color.mPrimary)
                }
            }
        }
    }
}
