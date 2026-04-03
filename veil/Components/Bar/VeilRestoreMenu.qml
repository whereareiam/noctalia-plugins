import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
    id: panelRoot

    property var pluginApi: null
    readonly property var mainInstance: pluginApi ? pluginApi.mainInstance : null
    readonly property var hiddenWindows: mainInstance ? mainInstance.hiddenWindows : []
    readonly property real contentPreferredWidth: 360 * Style.uiScaleRatio
    readonly property real maxListHeight: 320 * Style.uiScaleRatio
    readonly property real contentPreferredHeight: Math.min(420 * Style.uiScaleRatio, contentColumn.implicitHeight + Style.marginL * 2)
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    anchors.fill: parent

    Rectangle {
        id: panelContainer

        anchors.fill: parent
        color: Color.mSurface
        radius: Style.radiusL
        clip: true

        ColumnLayout {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginM

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                NIcon {
                    icon: "eye-off"
                    pointSize: Style.fontSizeL
                    color: Color.mPrimary
                }

                NText {
                    Layout.fillWidth: true
                    text: pluginApi && pluginApi.tr ? pluginApi.tr("panel.title") : "Hidden windows"
                    pointSize: Style.fontSizeL
                    font.weight: Style.fontWeightBold
                    color: Color.mOnSurface
                }

                NIconButton {
                    baseSize: Style.baseWidgetSize * 0.8
                    icon: "close"
                    tooltipText: pluginApi && pluginApi.tr ? pluginApi.tr("panel.close") : "Close"

                    onClicked: {
                        if (pluginApi && pluginApi.panelOpenScreen) {
                            pluginApi.closePanel(pluginApi.panelOpenScreen);
                        }
                    }
                }
            }

            NText {
                Layout.fillWidth: true
                visible: hiddenWindows.length === 0
                text: pluginApi && pluginApi.tr ? pluginApi.tr("panel.empty") : "No hidden windows."
                pointSize: Style.fontSizeM
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
            }

            ScrollView {
                id: listScroll

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(root.maxListHeight, listColumn.implicitHeight)
                visible: hiddenWindows.length > 0
                clip: true

                ColumnLayout {
                    id: listColumn

                    width: parent.width
                    spacing: Style.marginS

                    Repeater {
                        model: hiddenWindows

                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: Math.round(48 * Style.uiScaleRatio)
                            radius: Style.radiusM
                            color: mouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.10) : Qt.alpha(Color.mSurfaceVariant, 0.80)
                            border.color: mouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.35) : Qt.alpha(Color.mOutline, 0.45)
                            border.width: Style.borderS

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Style.marginM
                                anchors.rightMargin: Style.marginM
                                spacing: Style.marginM

                                IconImage {
                                    width: Math.round(24 * Style.uiScaleRatio)
                                    height: width
                                    source: ThemeIcons.iconForAppId(String(modelData.appId || ""))
                                    smooth: true
                                    asynchronous: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    NText {
                                        Layout.fillWidth: true
                                        text: String(modelData.title || modelData.appId || modelData.address || "")
                                        pointSize: Style.fontSizeS
                                        font.weight: Style.fontWeightSemiBold
                                        color: Color.mOnSurface
                                        elide: Text.ElideRight
                                    }

                                    NText {
                                        Layout.fillWidth: true
                                        text: String(modelData.appId || modelData.workspace || "")
                                        pointSize: Style.fontSizeXS
                                        color: Color.mOnSurfaceVariant
                                        elide: Text.ElideRight
                                    }
                                }

                                NIcon {
                                    icon: "arrow-up-right"
                                    pointSize: Style.fontSizeS
                                    color: Color.mPrimary
                                }
                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (panelRoot.mainInstance) {
                                        panelRoot.mainInstance.restore(String(modelData.address || ""));
                                    }

                                    if (panelRoot.pluginApi && panelRoot.pluginApi.panelOpenScreen) {
                                        panelRoot.pluginApi.closePanel(panelRoot.pluginApi.panelOpenScreen);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
