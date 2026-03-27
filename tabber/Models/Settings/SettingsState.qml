import QtQuick

import "../../Utils/ActionUtils.js" as ActionUtils
import "../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    property var pluginApi: null

    function paddingFallback(name, legacyName, fallback) {
        var value = SettingsUtils.settingNumber(pluginApi, defaults, name, NaN);
        if (!Number.isNaN(value)) {
            return value;
        }
        return SettingsUtils.settingNumber(pluginApi, defaults, legacyName, fallback);
    }

    readonly property var defaults: SettingsUtils.defaultsFromPlugin(pluginApi)
    readonly property int translationVersion: pluginApi ? pluginApi.translationVersion : 0
    readonly property string triggerKeybind: SettingsUtils.settingString(pluginApi, defaults, "triggerKeybind", "Alt+Tab")
    readonly property string reverseTriggerKeybind: SettingsUtils.settingString(pluginApi, defaults, "reverseTriggerKeybind", "Alt+Shift+Tab")
    readonly property bool groupWindowsByApp: SettingsUtils.settingBool(pluginApi, defaults, "groupWindowsByApp", true)
    readonly property bool showHiddenWindows: SettingsUtils.settingBool(pluginApi, defaults, "showHiddenWindows", true)
    readonly property real dimOpacity: SettingsUtils.settingNumber(pluginApi, defaults, "dimOpacity", 0.36)
    readonly property int cardSize: SettingsUtils.settingNumber(pluginApi, defaults, "cardSize", 108)
    readonly property int cardGap: SettingsUtils.settingNumber(pluginApi, defaults, "cardGap", 9)
    readonly property int iconSize: SettingsUtils.settingNumber(pluginApi, defaults, "iconSize", 64)
    readonly property int containerWidth: SettingsUtils.settingNumber(pluginApi, defaults, "containerWidth", 0)
    readonly property int containerPadding: SettingsUtils.settingNumber(pluginApi, defaults, "containerPadding", 18)
    readonly property bool containerPaddingLinked: SettingsUtils.settingBool(pluginApi, defaults, "containerPaddingLinked", true)
    readonly property int containerPaddingTop: paddingFallback("containerPaddingTop", "containerPadding", 18)
    readonly property int containerPaddingRight: paddingFallback("containerPaddingRight", "containerPadding", 18)
    readonly property int containerPaddingBottom: paddingFallback("containerPaddingBottom", "containerPadding", 18)
    readonly property int containerPaddingLeft: paddingFallback("containerPaddingLeft", "containerPadding", 18)
    readonly property bool showHeader: SettingsUtils.settingBool(pluginApi, defaults, "showHeader", true)
    readonly property string headerAlignment: SettingsUtils.settingString(pluginApi, defaults, "headerAlignment", "space-between")
    readonly property int headerPadding: SettingsUtils.settingNumber(pluginApi, defaults, "headerPadding", 0)
    readonly property bool headerPaddingLinked: SettingsUtils.settingBool(pluginApi, defaults, "headerPaddingLinked", true)
    readonly property int headerPaddingTop: paddingFallback("headerPaddingTop", "headerPadding", 0)
    readonly property int headerPaddingRight: paddingFallback("headerPaddingRight", "headerPadding", 0)
    readonly property int headerPaddingBottom: paddingFallback("headerPaddingBottom", "headerPadding", 0)
    readonly property int headerPaddingLeft: paddingFallback("headerPaddingLeft", "headerPadding", 0)
    readonly property string headerText: SettingsUtils.settingString(pluginApi, defaults, "headerText", "Tabber")
    readonly property bool showWindowCount: SettingsUtils.settingBool(pluginApi, defaults, "showWindowCount", true)
    readonly property string titleVisibility: SettingsUtils.settingString(pluginApi, defaults, "titleVisibility", "selected")
    readonly property string titleTruncationMode: SettingsUtils.settingString(pluginApi, defaults, "titleTruncationMode", "end")
    readonly property string closeKeybind: SettingsUtils.settingString(pluginApi, defaults, "closeKeybind", "Alt+Q")
    readonly property string closeScript: SettingsUtils.settingString(pluginApi, defaults, "closeScript", "scripts/close-selected-group.sh")
    readonly property string hideKeybind: SettingsUtils.settingString(pluginApi, defaults, "hideKeybind", "Alt+H")
    readonly property string hideScript: SettingsUtils.settingString(pluginApi, defaults, "hideScript", "scripts/hide-selected-group.sh")
    readonly property var seedActions: ActionUtils.createSeedActions(closeKeybind, closeScript, hideKeybind, hideScript)
    readonly property var effectiveActionSource: ActionUtils.firstActionSource(
            pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.actions : undefined,
        defaults ? defaults.actions : undefined,
        seedActions)
    readonly property var configuredActions: ActionUtils.resolveConfiguredActions(
        pluginApi,
            pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.actions : undefined,
        defaults ? defaults.actions : undefined,
        seedActions)

    property string editTriggerKeybind: triggerKeybind
    property string editReverseTriggerKeybind: reverseTriggerKeybind
    property bool editGroupWindowsByApp: groupWindowsByApp
    property bool editShowHiddenWindows: showHiddenWindows
    property string editDimOpacity: String(dimOpacity)
    property string editCardSize: String(cardSize)
    property string editCardGap: String(cardGap)
    property string editIconSize: String(iconSize)
    property string editContainerWidth: String(containerWidth)
    property bool editContainerPaddingLinked: containerPaddingLinked
    property string editContainerPaddingTop: String(containerPaddingTop)
    property string editContainerPaddingRight: String(containerPaddingRight)
    property string editContainerPaddingBottom: String(containerPaddingBottom)
    property string editContainerPaddingLeft: String(containerPaddingLeft)
    property bool editShowHeader: showHeader
    property string editHeaderAlignment: headerAlignment
    property bool editHeaderPaddingLinked: headerPaddingLinked
    property string editHeaderPaddingTop: String(headerPaddingTop)
    property string editHeaderPaddingRight: String(headerPaddingRight)
    property string editHeaderPaddingBottom: String(headerPaddingBottom)
    property string editHeaderPaddingLeft: String(headerPaddingLeft)
    property string editHeaderText: headerText
    property bool editShowWindowCount: showWindowCount
    property string editTitleVisibility: titleVisibility
    property string editTitleTruncationMode: titleTruncationMode
    property var editActions: ActionUtils.cloneActions(effectiveActionSource)

    function resetEditor() {
        editTriggerKeybind = triggerKeybind;
        editReverseTriggerKeybind = reverseTriggerKeybind;
        editGroupWindowsByApp = groupWindowsByApp;
        editShowHiddenWindows = showHiddenWindows;
        editDimOpacity = String(dimOpacity);
        editCardSize = String(cardSize);
        editCardGap = String(cardGap);
        editIconSize = String(iconSize);
        editContainerWidth = String(containerWidth);
        editContainerPaddingLinked = containerPaddingLinked;
        editContainerPaddingTop = String(containerPaddingTop);
        editContainerPaddingRight = String(containerPaddingRight);
        editContainerPaddingBottom = String(containerPaddingBottom);
        editContainerPaddingLeft = String(containerPaddingLeft);
        editShowHeader = showHeader;
        editHeaderAlignment = headerAlignment;
        editHeaderPaddingLinked = headerPaddingLinked;
        editHeaderPaddingTop = String(headerPaddingTop);
        editHeaderPaddingRight = String(headerPaddingRight);
        editHeaderPaddingBottom = String(headerPaddingBottom);
        editHeaderPaddingLeft = String(headerPaddingLeft);
        editHeaderText = headerText;
        editShowWindowCount = showWindowCount;
        editTitleVisibility = titleVisibility;
        editTitleTruncationMode = titleTruncationMode;
        editActions = ActionUtils.cloneActions(effectiveActionSource);
    }

    function addAction() {
        var next = ActionUtils.cloneActions(editActions);
        next.push({
            id: ActionUtils.makeActionId(),
            keybind: "",
            script: ""
        });
        editActions = next;
    }

    function removeAction(index) {
        var next = ActionUtils.cloneActions(editActions);
        if (index >= 0 && index < next.length) {
            next.splice(index, 1);
            editActions = next;
        }
    }

    function updateActionField(index, field, value) {
        var next = ActionUtils.cloneActions(editActions);
        if (index >= 0 && index < next.length) {
            next[index][field] = value;
            editActions = next;
        }
    }

    function updateActionKeybind(index, newKeybinds) {
        updateActionField(index, "keybind", (newKeybinds && newKeybinds.length > 0) ? newKeybinds[0] : "");
    }

    function setContainerPaddingValue(side, value) {
        if (editContainerPaddingLinked) {
            editContainerPaddingTop = value;
            editContainerPaddingRight = value;
            editContainerPaddingBottom = value;
            editContainerPaddingLeft = value;
            return;
        }

        if (side === "top") {
            editContainerPaddingTop = value;
        } else if (side === "right") {
            editContainerPaddingRight = value;
        } else if (side === "bottom") {
            editContainerPaddingBottom = value;
        } else if (side === "left") {
            editContainerPaddingLeft = value;
        }
    }

    function setHeaderPaddingValue(side, value) {
        if (editHeaderPaddingLinked) {
            editHeaderPaddingTop = value;
            editHeaderPaddingRight = value;
            editHeaderPaddingBottom = value;
            editHeaderPaddingLeft = value;
            return;
        }

        if (side === "top") {
            editHeaderPaddingTop = value;
        } else if (side === "right") {
            editHeaderPaddingRight = value;
        } else if (side === "bottom") {
            editHeaderPaddingBottom = value;
        } else if (side === "left") {
            editHeaderPaddingLeft = value;
        }
    }

    function setContainerPaddingLinked(linked) {
        editContainerPaddingLinked = linked;
        if (linked) {
            setContainerPaddingValue("top", editContainerPaddingTop);
        }
    }

    function setHeaderPaddingLinked(linked) {
        editHeaderPaddingLinked = linked;
        if (linked) {
            setHeaderPaddingValue("top", editHeaderPaddingTop);
        }
    }

    function saveSettings() {
        if (!pluginApi) {
            return;
        }

        var dim = parseFloat(editDimOpacity);
        if (Number.isNaN(dim)) {
            dim = defaults.dimOpacity !== undefined && defaults.dimOpacity !== null ? defaults.dimOpacity : 0.36;
        }

        var size = parseInt(editCardSize);
        if (Number.isNaN(size)) {
            size = defaults.cardSize !== undefined && defaults.cardSize !== null ? defaults.cardSize : 108;
        }

        var gap = parseInt(editCardGap);
        if (Number.isNaN(gap)) {
            gap = defaults.cardGap !== undefined && defaults.cardGap !== null ? defaults.cardGap : 9;
        }

        var icon = parseInt(editIconSize);
        if (Number.isNaN(icon)) {
            icon = defaults.iconSize !== undefined && defaults.iconSize !== null ? defaults.iconSize : 64;
        }

        var containerWidth = parseInt(editContainerWidth);
        if (Number.isNaN(containerWidth)) {
            containerWidth = defaults.containerWidth !== undefined && defaults.containerWidth !== null ? defaults.containerWidth : 0;
        }

        var containerPadTop = parseInt(editContainerPaddingTop);
        if (Number.isNaN(containerPadTop)) {
            containerPadTop = containerPaddingTop;
        }

        var containerPadRight = parseInt(editContainerPaddingRight);
        if (Number.isNaN(containerPadRight)) {
            containerPadRight = containerPaddingRight;
        }

        var containerPadBottom = parseInt(editContainerPaddingBottom);
        if (Number.isNaN(containerPadBottom)) {
            containerPadBottom = containerPaddingBottom;
        }

        var containerPadLeft = parseInt(editContainerPaddingLeft);
        if (Number.isNaN(containerPadLeft)) {
            containerPadLeft = containerPaddingLeft;
        }

        var headerPadTop = parseInt(editHeaderPaddingTop);
        if (Number.isNaN(headerPadTop)) {
            headerPadTop = headerPaddingTop;
        }

        var headerPadRight = parseInt(editHeaderPaddingRight);
        if (Number.isNaN(headerPadRight)) {
            headerPadRight = headerPaddingRight;
        }

        var headerPadBottom = parseInt(editHeaderPaddingBottom);
        if (Number.isNaN(headerPadBottom)) {
            headerPadBottom = headerPaddingBottom;
        }

        var headerPadLeft = parseInt(editHeaderPaddingLeft);
        if (Number.isNaN(headerPadLeft)) {
            headerPadLeft = headerPaddingLeft;
        }

        pluginApi.pluginSettings.triggerKeybind = editTriggerKeybind.trim() || (defaults.triggerKeybind || "Alt+Tab");
        pluginApi.pluginSettings.reverseTriggerKeybind = editReverseTriggerKeybind.trim() || (defaults.reverseTriggerKeybind || "Alt+Shift+Tab");
        pluginApi.pluginSettings.groupWindowsByApp = editGroupWindowsByApp;
        pluginApi.pluginSettings.showHiddenWindows = editShowHiddenWindows;
        pluginApi.pluginSettings.dimOpacity = SettingsUtils.clamp(dim, 0.1, 0.85);
        pluginApi.pluginSettings.cardSize = SettingsUtils.clamp(size, 64, 128);
        pluginApi.pluginSettings.cardGap = SettingsUtils.clamp(gap, 0, 48);
        pluginApi.pluginSettings.iconSize = SettingsUtils.clamp(icon, 24, 96);
        pluginApi.pluginSettings.containerWidth = containerWidth <= 0 ? 0 : SettingsUtils.clamp(containerWidth, 320, 2200);
        pluginApi.pluginSettings.containerPaddingLinked = editContainerPaddingLinked;
        pluginApi.pluginSettings.containerPaddingTop = SettingsUtils.clamp(containerPadTop, 8, 48);
        pluginApi.pluginSettings.containerPaddingRight = SettingsUtils.clamp(containerPadRight, 8, 48);
        pluginApi.pluginSettings.containerPaddingBottom = SettingsUtils.clamp(containerPadBottom, 8, 48);
        pluginApi.pluginSettings.containerPaddingLeft = SettingsUtils.clamp(containerPadLeft, 8, 48);
        pluginApi.pluginSettings.containerPadding = pluginApi.pluginSettings.containerPaddingTop;
        pluginApi.pluginSettings.showHeader = editShowHeader;
        pluginApi.pluginSettings.headerAlignment = editHeaderAlignment || (defaults.headerAlignment || "space-between");
        pluginApi.pluginSettings.headerPaddingLinked = editHeaderPaddingLinked;
        pluginApi.pluginSettings.headerPaddingTop = SettingsUtils.clamp(headerPadTop, 0, 36);
        pluginApi.pluginSettings.headerPaddingRight = SettingsUtils.clamp(headerPadRight, 0, 36);
        pluginApi.pluginSettings.headerPaddingBottom = SettingsUtils.clamp(headerPadBottom, 0, 36);
        pluginApi.pluginSettings.headerPaddingLeft = SettingsUtils.clamp(headerPadLeft, 0, 36);
        pluginApi.pluginSettings.headerPadding = pluginApi.pluginSettings.headerPaddingTop;
        pluginApi.pluginSettings.headerText = editHeaderText;
        pluginApi.pluginSettings.showWindowCount = editShowWindowCount;
        pluginApi.pluginSettings.titleVisibility = editTitleVisibility || (defaults.titleVisibility || "selected");
        pluginApi.pluginSettings.titleTruncationMode = editTitleTruncationMode || (defaults.titleTruncationMode || "end");

        var normalizedActions = [];
        for (var i = 0; i < editActions.length; i++) {
            var normalized = ActionUtils.normalizeAction(editActions[i], i);
            if (normalized.script.trim() === "") {
                continue;
            }
            normalizedActions.push(normalized);
        }

        pluginApi.pluginSettings.actions = normalizedActions;
        pluginApi.saveSettings();
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

    Component.onCompleted: resetEditor()
    onPluginApiChanged: resetEditor()
}
