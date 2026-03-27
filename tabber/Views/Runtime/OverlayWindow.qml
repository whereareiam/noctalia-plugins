import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../../Components/Runtime/Header" as HeaderComponents
import "../../Components/Runtime/Selection" as SelectionComponents
import qs.Commons
import qs.Widgets

PanelWindow {
    id: root

    required property var controller
    required property var session
    required property var groupModel
    required property var settingsState

    readonly property int containerPaddingTopPx: Math.round(root.settingsState.containerPaddingTop * Style.uiScaleRatio)
    readonly property int containerPaddingRightPx: Math.round(root.settingsState.containerPaddingRight * Style.uiScaleRatio)
    readonly property int containerPaddingBottomPx: Math.round(root.settingsState.containerPaddingBottom * Style.uiScaleRatio)
    readonly property int containerPaddingLeftPx: Math.round(root.settingsState.containerPaddingLeft * Style.uiScaleRatio)
    readonly property int configuredContainerWidth: root.settingsState.containerWidth > 0 ? Math.round(root.settingsState.containerWidth * Style.uiScaleRatio) : 0
    readonly property int headerPaddingTopPx: Math.round(root.settingsState.headerPaddingTop * Style.uiScaleRatio)
    readonly property int headerPaddingRightPx: Math.round(root.settingsState.headerPaddingRight * Style.uiScaleRatio)
    readonly property int headerPaddingBottomPx: Math.round(root.settingsState.headerPaddingBottom * Style.uiScaleRatio)
    readonly property int headerPaddingLeftPx: Math.round(root.settingsState.headerPaddingLeft * Style.uiScaleRatio)
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "tabber-" + (screen && screen.name ? screen.name : "unknown")
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Color.mSurface, Math.max(0.0, Math.min(0.85, root.settingsState.dimOpacity)))
    }

    FocusScope {
        id: overlayFocus

        anchors.fill: parent
        focus: true

        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: event => {
            if (root.controller.handleOverlayKeyPress(event)) {
                event.accepted = true;
            }
        }

        Keys.onReleased: event => {
            if (root.controller.handleOverlayKeyRelease(event)) {
                event.accepted = true;
            }
        }

        Item {
            id: overlayContainer

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(parent.width - Style.margin2XL * 2, contentColumn.implicitWidth + Style.margin2XL)
            height: switcherCard.implicitHeight

            ColumnLayout {
                anchors.fill: parent
                spacing: Style.marginL

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: overlayContainer.width
                    implicitWidth: overlayContainer.width
                    width: overlayContainer.width
                    implicitHeight: switcherCard.implicitHeight

                    NDropShadow {
                        anchors.fill: switcherCard
                        source: switcherCard
                        autoPaddingEnabled: true
                    }

                    Rectangle {
                        id: switcherCard

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        implicitHeight: contentColumn.implicitHeight + Style.margin2XL
                        radius: Style.radiusL
                        color: "transparent"
                        border.color: "transparent"
                        border.width: 0

                        ColumnLayout {
                            id: contentColumn

                            anchors.fill: parent
                            anchors.margins: Style.marginXL
                            spacing: Style.marginL

                            Rectangle {
                                id: unifiedContainer

                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: Math.max(root.configuredContainerWidth, groupStrip.implicitWidth) + root.containerPaddingLeftPx + root.containerPaddingRightPx
                                implicitHeight: unifiedColumn.implicitHeight + root.containerPaddingTopPx + root.containerPaddingBottomPx
                                radius: Style.radiusM
                                color: Qt.alpha(Color.mSurface, 0.74)
                                border.color: Qt.alpha(Color.mOutline, 0.45)
                                border.width: Style.borderS

                                ColumnLayout {
                                    id: unifiedColumn

                                    anchors.fill: parent
                                    anchors.leftMargin: root.containerPaddingLeftPx
                                    anchors.rightMargin: root.containerPaddingRightPx
                                    anchors.topMargin: root.containerPaddingTopPx
                                    anchors.bottomMargin: root.containerPaddingBottomPx
                                    spacing: root.settingsState.showHeader ? Style.marginXL : 0

                                    Loader {
                                        id: headerLoader

                                        active: root.settingsState.showHeader
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.fillWidth: true
                                        Layout.leftMargin: root.headerPaddingLeftPx
                                        Layout.rightMargin: root.headerPaddingRightPx
                                        Layout.topMargin: root.headerPaddingTopPx
                                        Layout.bottomMargin: root.headerPaddingBottomPx

                                        sourceComponent: HeaderComponents.SwitcherHeader {
                                            id: headerRow

                                            title: {
                                                root.settingsState.translationVersion;
                                                var configured = root.settingsState.headerText.trim();
                                                return configured !== "" ? configured : root.settingsState.tr("overlay.title", "Tabber");
                                            }
                                            headerAlignment: root.settingsState.headerAlignment
                                            showWindowCount: root.settingsState.showWindowCount
                                            windowCount: root.session.selectedGroup ? root.session.selectedGroup.windowCount : 0
                                            windowCountText: {
                                                root.settingsState.translationVersion;
                                                var count = root.session.selectedGroup ? root.session.selectedGroup.windowCount : 0;
                                                return root.settingsState.trp("overlay.windowCount", count, "{count} window", "{count} windows", {
                                                                                 count: count
                                                                             });
                                            }
                                        }
                                    }

                                    SelectionComponents.GroupStrip {
                                        id: groupStrip

                                        Layout.alignment: Qt.AlignHCenter
                                        groups: root.groupModel.displayGroups
                                        selectedGroupId: root.session.selectedGroupId
                                        cardSize: root.settingsState.cardSize
                                        cardGap: root.settingsState.cardGap
                                        iconSize: root.settingsState.iconSize
                                        titleVisibility: root.settingsState.titleVisibility
                                        titleTruncationMode: root.settingsState.titleTruncationMode
                                        onGroupHovered: groupId => {
                                            root.session.selectedGroupId = groupId;
                                            root.groupModel.updateDisplayGroups();
                                        }
                                        onGroupActivated: groupId => {
                                            if (groupId === root.session.selectedGroupId) {
                                                root.controller.acceptSelection();
                                            } else {
                                                root.session.selectedGroupId = groupId;
                                                root.groupModel.updateDisplayGroups();
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
    }
}
