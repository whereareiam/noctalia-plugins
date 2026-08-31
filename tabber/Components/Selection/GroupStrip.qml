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
    property bool hoverSelectionEnabled: true

    readonly property int gapPx: Math.round(root.cardGap * Style.uiScaleRatio)
    readonly property bool titlesVisible: root.titleVisibility !== "hidden"
    readonly property bool allTitlesVisible: root.titleVisibility === "all"
    readonly property bool selectedTitleVisible: root.titleVisibility === "selected"
    readonly property int tileWidth: Math.round((root.cardSize + 28) * Style.uiScaleRatio)
    readonly property int selectedIndex: {
        for (var index = 0; index < root.groups.length; index++) {
            if (root.groups[index] && root.groups[index].groupId === root.selectedGroupId) {
                return index;
            }
        }
        return -1;
    }
    readonly property var selectedGroupData: selectedIndex >= 0 && selectedIndex < root.groups.length
        ? root.groups[selectedIndex]
        : null

    signal groupHovered(string groupId)

    signal groupActivated(string groupId)

    spacing: root.titlesVisible ? root.gapPx : 0
    implicitWidth: Math.max(displayRow.implicitWidth, titlesRow.implicitWidth, selectedTitleTrack.implicitWidth)
    implicitHeight: displayRow.implicitHeight + (root.titlesVisible ? (spacing + Math.max(titlesRow.implicitHeight, selectedTitleTrack.implicitHeight)) : 0)

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
                hoverSelectionEnabled: root.hoverSelectionEnabled
                selected: modelData.groupId === root.selectedGroupId
                onHoverSelected: root.groupHovered(modelData.groupId)
                onActivateSelected: root.groupActivated(modelData.groupId)
            }
        }
    }

    Row {
        id: titlesRow

        visible: root.allTitlesVisible
        spacing: root.gapPx

        Repeater {
            model: root.groups

            delegate: SelectionComponents.TitleSlot
            {
                required property var modelData

                titleData: modelData
                cardSize: root.cardSize
                titleVisibility: "all"
                titleTruncationMode: root.titleTruncationMode
                selected: modelData.groupId === root.selectedGroupId
            }
        }
    }

    Item {
        id: selectedTitleTrack

        visible: root.selectedTitleVisible && root.selectedGroupData !== null
        implicitWidth: displayRow.implicitWidth
        implicitHeight: selectedTitleLoader.active && selectedTitleLoader.item ? selectedTitleLoader.item.height : 0

        Loader {
            id: selectedTitleLoader

            active: root.selectedTitleVisible && root.selectedGroupData !== null
            x: Math.max(0, root.selectedIndex) * (root.tileWidth + root.gapPx)

            sourceComponent: SelectionComponents.TitleSlot {
                titleData: root.selectedGroupData
                cardSize: root.cardSize
                titleVisibility: "selected"
                titleTruncationMode: root.titleTruncationMode
                selected: true
            }
        }
    }
}
