import QtQuick
import QtQuick.Layouts

import qs.Commons
import "." as SelectionComponents

ColumnLayout {
    id: root

    property var groups: []
    property string selectedGroupId: ""
    property int cardSize: 108
    property int cardGap: 9
    property int iconSize: 64
    property string titleVisibility: "selected"
    property string titleTruncationMode: "end"

    readonly property int gapPx: Math.round(root.cardGap * Style.uiScaleRatio)
    readonly property bool titlesVisible: root.titleVisibility !== "hidden"

    signal groupHovered(string groupId)

    signal groupActivated(string groupId)

    spacing: root.titlesVisible ? root.gapPx : 0
    implicitWidth: Math.max(displayRow.implicitWidth, titlesRow.implicitWidth)
    implicitHeight: displayRow.implicitHeight + (root.titlesVisible ? (spacing + titlesRow.implicitHeight) : 0)

    Row {
        id: displayRow

        spacing: root.gapPx

        Repeater {
            model: root.groups

            delegate: SelectionComponents.GroupCard
            {
                required property var modelData

                groupData: modelData
                cardSize: root.cardSize
                iconSizeValue: root.iconSize
                selected: modelData.groupId === root.selectedGroupId
                onHoverSelected: root.groupHovered(modelData.groupId)
                onActivateSelected: root.groupActivated(modelData.groupId)
            }
        }
    }

    Row {
        id: titlesRow

        visible: root.titlesVisible
        spacing: root.gapPx

        Repeater {
            model: root.groups

            delegate: SelectionComponents.TitleSlot
            {
                required property var modelData

                titleData: modelData
                cardSize: root.cardSize
                titleVisibility: root.titleVisibility
                titleTruncationMode: root.titleTruncationMode
                selected: modelData.groupId === root.selectedGroupId
            }
        }
    }
}
