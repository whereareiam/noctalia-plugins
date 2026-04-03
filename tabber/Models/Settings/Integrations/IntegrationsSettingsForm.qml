import QtQuick

QtObject {
    id: root

    required property var settings

    readonly property QtObject veil: VeilIntegrationSettingsForm {
        settings: root.settings.veil
    }

    function reset() {
        veil.reset();
    }

    function persist(target) {
        veil.persist(target);
    }
}
