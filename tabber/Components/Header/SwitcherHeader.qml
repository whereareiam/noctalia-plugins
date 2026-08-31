import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets
import "." as HeaderComponents

RowLayout {
    id: root

    property string title: "Tabber"
    property string headerAlignment: "space-between"
    property bool showWindowCount: true
    property int windowCount: 0
    property string windowCountText: ""

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginM

    Item {
        visible: root.headerAlignment === "center"
        Layout.fillWidth: visible
    }

    NText {
        text: root.title
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    Item {
        visible: root.headerAlignment === "space-between" && root.showWindowCount
        Layout.fillWidth: visible
    }

    HeaderComponents.HeaderBadge {
        visible: root.showWindowCount
        text: root.windowCountText !== "" ? root.windowCountText : (root.windowCount + " window" + (root.windowCount === 1 ? "" : "s"))
    }

    Item {
        visible: root.headerAlignment === "center"
        Layout.fillWidth: visible
    }
}
