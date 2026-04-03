import QtQuick

import "../../Utils/SettingsUtils.js" as SettingsUtils
import "./General" as GeneralSettings
import "./Appearance" as AppearanceSettings
import "./Actions" as ActionSettings
import "./Integrations" as IntegrationSettings
import "./Preview" as PreviewSettings

QtObject {
    id: root

    property var pluginApi: null

    readonly property var defaults: SettingsUtils.defaultsFromPlugin(pluginApi)
    readonly property int translationVersion: pluginApi ? pluginApi.translationVersion : 0
    readonly property QtObject general: GeneralSettings.GeneralSettings {
        settingsStore: root
    }
    readonly property QtObject appearance: AppearanceSettings.AppearanceSettings {
        settingsStore: root
    }
    readonly property QtObject actions: ActionSettings.ActionSettings {
        settingsStore: root
    }
    readonly property QtObject integrations: IntegrationSettings.IntegrationsSettings {
        settingsStore: root
    }
    readonly property QtObject preview: PreviewSettings.PreviewSettings {
        settingsStore: root
    }

    function tr(key, fallback, interpolations) {
        if (pluginApi && pluginApi.tr) {
            return pluginApi.tr(key, interpolations || {});
        }
        return fallback;
    }

    function trp(key, count, fallbackSingular, fallbackPlural, interpolations) {
        if (pluginApi && pluginApi.trp) {
            return pluginApi.trp(key, count, interpolations || {});
        }
        return count === 1 ? fallbackSingular.replace("{count}", count) : fallbackPlural.replace("{count}", count);
    }
}
