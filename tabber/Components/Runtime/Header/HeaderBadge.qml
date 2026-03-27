import QtQuick

import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    property string text: ""

    radius: Style.iRadiusS
    color: Qt.alpha(Color.mPrimary, 0.14)
    border.color: Qt.alpha(Color.mPrimary, 0.35)
    border.width: Style.borderS
    implicitHeight: badgeText.implicitHeight + Style.marginS
    implicitWidth: badgeText.implicitWidth + Style.marginM

    NText {
        id: badgeText

        anchors.centerIn: parent
        text: root.text
        pointSize: Style.fontSizeS
        color: Color.mPrimary
        font.weight: Style.fontWeightSemiBold
    }
}
