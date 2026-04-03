import QtQuick

import "../../../Utils/ActionUtils.js" as ActionUtils
import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    readonly property var pluginActionSource: {
        var pluginSettings = settingsStore && settingsStore.pluginApi ? settingsStore.pluginApi.pluginSettings : null;
        var nestedValue = SettingsUtils.pathValue(pluginSettings, "actions.items");
        if (Array.isArray(nestedValue)) {
            return nestedValue;
        }

        var legacyValue = SettingsUtils.pathValue(pluginSettings, "actions");
        return Array.isArray(legacyValue) ? legacyValue : undefined;
    }
    readonly property var defaultActionSource: {
        var nestedValue = SettingsUtils.pathValue(settingsStore.defaults, "actions.items");
        if (Array.isArray(nestedValue)) {
            return nestedValue;
        }

        var legacyValue = SettingsUtils.pathValue(settingsStore.defaults, "actions");
        return Array.isArray(legacyValue) ? legacyValue : undefined;
    }
    readonly property var effectiveActionSource: ActionUtils.firstActionSource(pluginActionSource, defaultActionSource)
    readonly property var configuredActions: ActionUtils.resolveConfiguredActions(settingsStore.pluginApi, pluginActionSource, defaultActionSource)
}
