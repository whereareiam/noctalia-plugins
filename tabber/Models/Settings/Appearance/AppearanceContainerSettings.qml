import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    function paddingFallback(name, legacyName, fallback) {
        var value = SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding." + name, legacyName], NaN);
        if (!Number.isNaN(value)) {
            return value;
        }
        return fallback;
    }

    readonly property int width: SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.width", "containerWidth"], 0)
    readonly property bool paddingLinked: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding.linked", "containerPaddingLinked"], true)
    readonly property int paddingTop: paddingFallback("top", "containerPaddingTop", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding.all", "containerPadding"], 18))
    readonly property int paddingRight: paddingFallback("right", "containerPaddingRight", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding.all", "containerPadding"], 18))
    readonly property int paddingBottom: paddingFallback("bottom", "containerPaddingBottom", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding.all", "containerPadding"], 18))
    readonly property int paddingLeft: paddingFallback("left", "containerPaddingLeft", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.container.padding.all", "containerPadding"], 18))
}
