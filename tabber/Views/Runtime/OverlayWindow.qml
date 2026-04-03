import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../../Components/Runtime/Overlay" as OverlayComponents
import qs.Commons

PanelWindow {
    id: root

    required property var controller
    required property var session
    required property var groupModel
    required property var selectionModel
    required property var settingsStore

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
        color: Qt.alpha(Color.mSurface, Math.max(0.0, Math.min(0.85, root.settingsStore.appearance.dimOpacity)))
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
            width: Math.min(parent.width - Style.margin2XL * 2, overlaySurface.implicitWidth)
            height: overlaySurface.implicitHeight

            OverlayComponents.SwitcherSurface {
                id: overlaySurface

                anchors.centerIn: parent
                settingsStore: root.settingsStore
                appearanceSettings: root.settingsStore.appearance
                selectedGroup: root.session.selectedGroup
                selectedGroupId: root.session.selectedGroupId
                displayGroups: root.selectionModel.displayGroups
                onGroupHovered: groupId => root.selectionModel.selectGroup(groupId)
                onGroupActivated: groupId => {
                    if (groupId === root.session.selectedGroupId) {
                        root.controller.acceptSelection();
                    } else {
                        root.selectionModel.selectGroup(groupId);
                    }
                }
            }
        }
    }
}
