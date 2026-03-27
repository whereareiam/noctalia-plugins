import QtQuick

import "./Models/Runtime" as RuntimeModels
import "./Models/Settings" as SettingsModels
import "./Services/Runtime" as RuntimeServices
import "./Views/Runtime" as RuntimeViews
import qs.Services.Compositor

Item {
    id: root

    property var pluginApi: null

    SettingsModels.SettingsState {
        id: settingsState

        pluginApi: root.pluginApi
    }

    RuntimeModels.Session {
        id: session
    }

    RuntimeModels.GroupModel {
        id: groupModel

        session: session
        settingsState: settingsState
    }

    RuntimeModels.ActionRegistry {
        id: actionRegistry

        settingsState: settingsState
    }

    RuntimeServices.Controller {
        id: controller

        pluginApi: root.pluginApi
        settingsState: settingsState
        session: session
        groupModel: groupModel
        actionRegistry: actionRegistry
    }

    RuntimeServices.ShortcutService {
        controller: controller
    }

    RuntimeViews.Overlay {
        controller: controller
        session: session
        groupModel: groupModel
        settingsState: settingsState
    }

    Component.onCompleted: controller.initialize()

    Connections {
        target: CompositorService

        function onActiveWindowChanged() {
            controller.handleActiveWindowChanged();
        }

        function onWindowListChanged() {
            controller.handleWindowListChanged();
        }
    }
}
