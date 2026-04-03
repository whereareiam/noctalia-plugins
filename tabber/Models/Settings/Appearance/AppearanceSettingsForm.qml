import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property string dimOpacity: settings ? String(settings.dimOpacity) : "0.36"
    readonly property QtObject container: AppearanceContainerSettingsForm {
        settings: root.settings.container
    }
    readonly property QtObject header: AppearanceHeaderSettingsForm {
        settings: root.settings.header
    }
    readonly property QtObject selection: AppearanceSelectionSettingsForm {
        settings: root.settings.selection
    }

    function reset() {
        dimOpacity = String(settings.dimOpacity);
        container.reset();
        header.reset();
        selection.reset();
    }

    function persist(target) {
        var parsedDimOpacity = parseFloat(dimOpacity);
        if (Number.isNaN(parsedDimOpacity)) {
            parsedDimOpacity = settings.dimOpacity;
        }

        SettingsUtils.clearPaths(target, ["dimOpacity"]);
        SettingsUtils.setPathValue(target, "appearance.dimOpacity", SettingsUtils.clamp(parsedDimOpacity, 0.1, 0.85));
        container.persist(target);
        header.persist(target);
        selection.persist(target);
    }
}
