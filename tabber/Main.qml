import QtQuick

import "./Models/Runtime" as RuntimeModels
import "./Models/Settings" as SettingsModels
import "./Services" as Services
import "./Views/Runtime" as RuntimeViews
import qs.Services.Compositor

Item {
    id: root

    property var pluginApi: null

    SettingsModels.SettingsStore {
        id: settingsStore

        pluginApi: root.pluginApi
    }

    RuntimeModels.Session {
        id: session
    }

    RuntimeModels.GroupModel {
        id: groupModel

        session: session
        settingsStore: settingsStore
    }

    RuntimeModels.SelectionModel {
        id: selectionModel

        session: session
        groupModel: groupModel
    }

    RuntimeModels.ActionRegistry {
        id: actionRegistry

        settingsStore: settingsStore
    }

    Services.TabberController {
        id: controller

        pluginApi: root.pluginApi
        settingsStore: settingsStore
        session: session
        groupModel: groupModel
        selectionModel: selectionModel
        actionRegistry: actionRegistry
    }

    Services.ShortcutBindings {
        controller: controller
    }

    RuntimeViews.Overlay {
        controller: controller
        session: session
        groupModel: groupModel
        selectionModel: selectionModel
        settingsStore: settingsStore
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
