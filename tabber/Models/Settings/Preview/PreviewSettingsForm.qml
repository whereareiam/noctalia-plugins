import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property bool enabled: settings ? settings.enabled : false

    function reset() {
        enabled = settings.enabled;
    }

    function persist(target) {
        SettingsUtils.setPathValue(target, "preview.enabled", enabled);
    }
}
