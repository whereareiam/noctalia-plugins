import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property string cardSize: settings ? String(settings.cardSize) : "108"
    property string cardGap: settings ? String(settings.cardGap) : "9"
    property string iconSize: settings ? String(settings.iconSize) : "64"
    property string titleVisibility: settings ? settings.titleVisibility : "selected"
    property string titleTruncationMode: settings ? settings.titleTruncationMode : "end"

    function reset() {
        cardSize = String(settings.cardSize);
        cardGap = String(settings.cardGap);
        iconSize = String(settings.iconSize);
        titleVisibility = settings.titleVisibility;
        titleTruncationMode = settings.titleTruncationMode;
    }

    function persist(target) {
        var parsedCardSize = parseInt(cardSize);
        if (Number.isNaN(parsedCardSize)) {
            parsedCardSize = settings.cardSize;
        }

        var parsedCardGap = parseInt(cardGap);
        if (Number.isNaN(parsedCardGap)) {
            parsedCardGap = settings.cardGap;
        }

        var parsedIconSize = parseInt(iconSize);
        if (Number.isNaN(parsedIconSize)) {
            parsedIconSize = settings.iconSize;
        }

        SettingsUtils.clearPaths(target, [
                                    "cardSize",
                                    "cardGap",
                                    "iconSize",
                                    "appearance.selection.highlightHiddenCards",
                                    "appearance.selection.hiddenCardAccentColor",
                                    "titleVisibility",
                                    "titleTruncationMode"
                                ]);
        SettingsUtils.setPathValue(target, "appearance.selection.cardSize", SettingsUtils.clamp(parsedCardSize, 64, 128));
        SettingsUtils.setPathValue(target, "appearance.selection.cardGap", SettingsUtils.clamp(parsedCardGap, 0, 48));
        SettingsUtils.setPathValue(target, "appearance.selection.iconSize", SettingsUtils.clamp(parsedIconSize, 24, 96));
        SettingsUtils.setPathValue(target, "appearance.selection.titleVisibility", titleVisibility || "selected");
        SettingsUtils.setPathValue(target, "appearance.selection.titleTruncationMode", titleTruncationMode || "end");
    }
}
