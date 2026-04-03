import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property bool enabled: settings ? settings.enabled : true
    property bool highlightHiddenCards: settings ? settings.highlightHiddenCards : true
    property string hiddenCardAccentColor: settings ? settings.hiddenCardAccentColor : ""

    function reset() {
        enabled = settings.enabled;
        highlightHiddenCards = settings.highlightHiddenCards;
        hiddenCardAccentColor = settings.hiddenCardAccentColor;
    }

    function persist(target) {
        var normalizedHiddenCardAccentColor = String(hiddenCardAccentColor || "").trim();
        if (normalizedHiddenCardAccentColor !== "" && !SettingsUtils.isHexColorString(normalizedHiddenCardAccentColor)) {
            normalizedHiddenCardAccentColor = String(settings.hiddenCardAccentColor || "").trim();
        }

        SettingsUtils.clearPaths(target, ["integrations.veil.hiddenCardAccentColor"]);
        SettingsUtils.setPathValue(target, "integrations.veil.enabled", enabled);
        SettingsUtils.setPathValue(target, "integrations.veil.highlightHiddenCards", highlightHiddenCards === true);
        if (normalizedHiddenCardAccentColor !== "") {
            SettingsUtils.setPathValue(target, "integrations.veil.hiddenCardAccentColor", normalizedHiddenCardAccentColor);
        }
    }
}
