import QtQuick

import "./Integrations" as IntegrationModels
import "./Integrations/Veil" as VeilIntegrationModels
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
        sourceEntries: windowCatalog.entries
    }

    RuntimeModels.SelectionModel {
        id: selectionModel

        session: session
        groupModel: groupModel
    }

    VeilIntegrationModels.VeilPluginState {
        id: veilPluginState
    }

    VeilIntegrationModels.VeilHiddenWindowsSource {
        id: veilHiddenWindowsSource

        veilPluginState: veilPluginState
    }

    VeilIntegrationModels.VeilIntegration {
        id: veilIntegration

        settingsStore: settingsStore
        pluginState: veilPluginState
        hiddenWindowsSource: veilHiddenWindowsSource
    }

    IntegrationModels.IntegrationRegistry {
        id: integrationRegistry

        providers: [veilIntegration]
    }

    RuntimeModels.ActionRegistry {
        id: actionRegistry

        settingsStore: settingsStore
    }

    Services.WindowCatalog {
        id: windowCatalog

        session: session
        settingsStore: settingsStore
        integrationRegistry: integrationRegistry
    }

    Services.TabberController {
        id: controller

        pluginApi: root.pluginApi
        settingsStore: settingsStore
        session: session
        windowCatalog: windowCatalog
        integrationRegistry: integrationRegistry
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

    Connections {
        target: session

        function onOverlayVisibleChanged() {
            controller.publishSelectionContext();
        }

        function onSelectedGroupChanged() {
            controller.publishSelectionContext();
        }
    }
}
