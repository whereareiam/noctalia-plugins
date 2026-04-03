import QtQuick

import "./Models/Runtime" as RuntimeModels
import "./Services" as Services
import qs.Services.Compositor

Item {
    id: root

    property var pluginApi: null
    readonly property var hiddenWindows: hiddenWindowsModel.windows
    readonly property int hiddenWindowCount: hiddenWindowsModel.hiddenCount

    RuntimeModels.HiddenWindowsModel {
        id: hiddenWindowsModel
    }

    Services.VeilStateStore {
        id: stateStore

        hiddenWindowsModel: hiddenWindowsModel
    }

    Services.VeilController {
        id: controller

        pluginApi: root.pluginApi
        hiddenWindowsModel: hiddenWindowsModel
        stateStore: stateStore
    }

    Services.VeilIpc {
        controller: controller
    }

    Services.VeilActions {
        controller: controller
    }

    function toggleFocused() {
        return controller.toggleFocused();
    }

    function hide(address) {
        return controller.hideWindow(address);
    }

    function restore(address) {
        return controller.restoreWindow(address);
    }

    function openRestoreMenu() {
        return controller.openRestoreMenu();
    }

    Component.onCompleted: controller.initialize()

    Connections {
        target: CompositorService

        function onWindowListChanged() {
            controller.pruneStaleWindows();
        }
    }
}
