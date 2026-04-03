import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settingsStore

    function paddingFallback(name, legacyName, fallback) {
        var value = SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding." + name, legacyName], NaN);
        if (!Number.isNaN(value)) {
            return value;
        }
        return fallback;
    }

    readonly property bool show: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.show", "showHeader"], true)
    readonly property string alignment: SettingsUtils.settingString(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.alignment", "headerAlignment"], "space-between")
    readonly property string text: SettingsUtils.settingString(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.text", "headerText"], "Tabber")
    readonly property bool showWindowCount: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.showWindowCount", "showWindowCount"], true)
    readonly property bool paddingLinked: SettingsUtils.settingBool(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding.linked", "headerPaddingLinked"], true)
    readonly property int paddingTop: paddingFallback("top", "headerPaddingTop", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding.all", "headerPadding"], 0))
    readonly property int paddingRight: paddingFallback("right", "headerPaddingRight", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding.all", "headerPadding"], 0))
    readonly property int paddingBottom: paddingFallback("bottom", "headerPaddingBottom", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding.all", "headerPadding"], 0))
    readonly property int paddingLeft: paddingFallback("left", "headerPaddingLeft", SettingsUtils.settingNumber(settingsStore.pluginApi, settingsStore.defaults, ["appearance.header.padding.all", "headerPadding"], 0))
}
