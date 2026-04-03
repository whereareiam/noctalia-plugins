import QtQuick
import "./General" as GeneralSettings
import "./Appearance" as AppearanceSettings
import "./Actions" as ActionSettings
import "./Integrations" as IntegrationSettings
import "./Preview" as PreviewSettings

QtObject {
    id: root

    required property var settingsStore

    readonly property QtObject general: GeneralSettings.GeneralSettingsForm {
        settings: root.settingsStore.general
    }
    readonly property QtObject appearance: AppearanceSettings.AppearanceSettingsForm {
        settings: root.settingsStore.appearance
    }
    readonly property QtObject actions: ActionSettings.ActionSettingsForm {
        settings: root.settingsStore.actions
    }
    readonly property QtObject integrations: IntegrationSettings.IntegrationsSettingsForm {
        settings: root.settingsStore.integrations
    }
    readonly property QtObject preview: PreviewSettings.PreviewSettingsForm {
        settings: root.settingsStore.preview
    }

    function resetEditor() {
        general.reset();
        appearance.reset();
        actions.reset();
        integrations.reset();
        preview.reset();
    }

    function saveSettings() {
        var pluginApi = settingsStore ? settingsStore.pluginApi : null;
        if (!pluginApi) {
            return;
        }

        if (!pluginApi.pluginSettings) {
            pluginApi.pluginSettings = ({});
        }

        general.persist(pluginApi.pluginSettings);
        appearance.persist(pluginApi.pluginSettings);
        preview.persist(pluginApi.pluginSettings);
        actions.persist(pluginApi.pluginSettings);
        integrations.persist(pluginApi.pluginSettings);
        pluginApi.saveSettings();
    }
}
