import QtQuick
import Quickshell

Item {
    id: root

    required property var controller
    required property var session
    required property var groupModel
    required property var selectionModel
    required property var settingsStore

    Variants {
        model: Quickshell.screens

        delegate: Loader {
            id: overlayLoader

            required property ShellScreen modelData

            active: root.session.overlayVisible && root.session.activeScreenName === modelData.name

            sourceComponent: OverlayWindow {
                screen: overlayLoader.modelData
                controller: root.controller
                session: root.session
                groupModel: root.groupModel
                selectionModel: root.selectionModel
                settingsStore: root.settingsStore
            }
        }
    }
}
