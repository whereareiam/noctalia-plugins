import QtQuick

QtObject {
    id: root

    required property var settingsStore

    readonly property QtObject veil: VeilIntegrationSettings {
        settingsStore: root.settingsStore
    }
}
