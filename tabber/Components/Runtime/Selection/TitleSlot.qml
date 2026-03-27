import QtQuick

import qs.Commons
import qs.Widgets

Item {
    id: root

    required property var titleData
    property bool selected: false
    property int cardSize: 108
    property string titleVisibility: "selected"
    property string titleTruncationMode: "end"

    readonly property int slotWidth: Math.round((cardSize + 28) * Style.uiScaleRatio)
    readonly property bool titleVisible: root.titleVisibility === "all" || (root.titleVisibility === "selected" && root.selected)
    readonly property bool twoLineMode: root.titleTruncationMode === "two-lines"

    width: slotWidth
    height: root.titleVisible ? Math.max(titleText.implicitHeight, Math.round((root.twoLineMode ? 36 : 24) * Style.uiScaleRatio)) : 0

    NText {
        id: titleText

        anchors.centerIn: parent
        width: parent.width
        visible: root.titleVisible
        text: root.titleData.primaryTitle
        pointSize: Style.fontSizeS
        font.weight: root.selected ? Style.fontWeightSemiBold : Style.fontWeightMedium
        color: root.selected ? Color.mOnSurface : Color.mOnSurfaceVariant
        wrapMode: root.twoLineMode ? Text.Wrap : Text.NoWrap
        maximumLineCount: root.twoLineMode ? 2 : 1
        elide: root.titleTruncationMode === "middle" ? Text.ElideMiddle : Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
    }
}
