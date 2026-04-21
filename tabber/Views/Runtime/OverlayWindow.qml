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

    property bool hoverSelectionUnlocked: !(root.settingsStore && root.settingsStore.general && root.settingsStore.general.requirePointerMovementForHoverSelection === true)
    property real hoverUnlockOriginX: NaN
    property real hoverUnlockOriginY: NaN
    readonly property real hoverUnlockDistancePx: Math.max(4, Math.round(6 * Style.uiScaleRatio))

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

    function updateHoverUnlock(position) {
        if (root.hoverSelectionUnlocked || !(root.settingsStore && root.settingsStore.general && root.settingsStore.general.requirePointerMovementForHoverSelection === true)) {
            root.hoverSelectionUnlocked = true;
            return;
        }

        var positionX = Number(position && position.x);
        var positionY = Number(position && position.y);
        if (!Number.isFinite(positionX) || !Number.isFinite(positionY)) {
            return;
        }

        if (!Number.isFinite(root.hoverUnlockOriginX) || !Number.isFinite(root.hoverUnlockOriginY)) {
            root.hoverUnlockOriginX = positionX;
            root.hoverUnlockOriginY = positionY;
            return;
        }

        var deltaX = positionX - root.hoverUnlockOriginX;
        var deltaY = positionY - root.hoverUnlockOriginY;
        if ((deltaX * deltaX) + (deltaY * deltaY) >= (root.hoverUnlockDistancePx * root.hoverUnlockDistancePx)) {
            root.hoverSelectionUnlocked = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Color.mSurface, Math.max(0.0, Math.min(0.85, root.settingsStore.appearance.dimOpacity)))
    }

    HoverHandler {
        id: pointerTracker

        onPointChanged: root.updateHoverUnlock(point.position)
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
                selectedGroupId: root.selectionModel.displaySelectedId
                displayGroups: root.selectionModel.displayGroups
                hoverSelectionEnabled: root.hoverSelectionUnlocked
                onGroupHovered: groupId => {
                    if (root.hoverSelectionUnlocked) {
                        root.selectionModel.selectDisplayItem(groupId);
                    }
                }
                onGroupActivated: groupId => {
                    if (groupId === root.selectionModel.displaySelectedId) {
                        root.controller.acceptSelection();
                    } else {
                        root.selectionModel.selectDisplayItem(groupId);
                    }
                }
            }
        }
    }
}
