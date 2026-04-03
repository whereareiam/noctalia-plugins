import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property bool show: settings ? settings.show : true
    property string alignment: settings ? settings.alignment : "space-between"
    property string text: settings ? settings.text : "Tabber"
    property bool showWindowCount: settings ? settings.showWindowCount : true
    property bool paddingLinked: settings ? settings.paddingLinked : true
    property string paddingTop: settings ? String(settings.paddingTop) : "0"
    property string paddingRight: settings ? String(settings.paddingRight) : "0"
    property string paddingBottom: settings ? String(settings.paddingBottom) : "0"
    property string paddingLeft: settings ? String(settings.paddingLeft) : "0"

    function reset() {
        show = settings.show;
        alignment = settings.alignment;
        text = settings.text;
        showWindowCount = settings.showWindowCount;
        paddingLinked = settings.paddingLinked;
        paddingTop = String(settings.paddingTop);
        paddingRight = String(settings.paddingRight);
        paddingBottom = String(settings.paddingBottom);
        paddingLeft = String(settings.paddingLeft);
    }

    function setPaddingValue(side, value) {
        if (paddingLinked) {
            paddingTop = value;
            paddingRight = value;
            paddingBottom = value;
            paddingLeft = value;
            return;
        }

        if (side === "top") {
            paddingTop = value;
        } else if (side === "right") {
            paddingRight = value;
        } else if (side === "bottom") {
            paddingBottom = value;
        } else if (side === "left") {
            paddingLeft = value;
        }
    }

    function setPaddingLinked(linked) {
        paddingLinked = linked;
        if (linked) {
            setPaddingValue("top", paddingTop);
        }
    }

    function persist(target) {
        var parsedTop = parseInt(paddingTop);
        if (Number.isNaN(parsedTop)) {
            parsedTop = settings.paddingTop;
        }

        var parsedRight = parseInt(paddingRight);
        if (Number.isNaN(parsedRight)) {
            parsedRight = settings.paddingRight;
        }

        var parsedBottom = parseInt(paddingBottom);
        if (Number.isNaN(parsedBottom)) {
            parsedBottom = settings.paddingBottom;
        }

        var parsedLeft = parseInt(paddingLeft);
        if (Number.isNaN(parsedLeft)) {
            parsedLeft = settings.paddingLeft;
        }

        SettingsUtils.clearPaths(target, [
                                    "showHeader",
                                    "headerAlignment",
                                    "headerText",
                                    "showWindowCount",
                                    "headerPadding",
                                    "headerPaddingLinked",
                                    "headerPaddingTop",
                                    "headerPaddingRight",
                                    "headerPaddingBottom",
                                    "headerPaddingLeft"
                                ]);
        SettingsUtils.setPathValue(target, "appearance.header.show", show);
        SettingsUtils.setPathValue(target, "appearance.header.alignment", alignment || "space-between");
        SettingsUtils.setPathValue(target, "appearance.header.text", text);
        SettingsUtils.setPathValue(target, "appearance.header.showWindowCount", showWindowCount);
        SettingsUtils.setPathValue(target, "appearance.header.padding.linked", paddingLinked);
        SettingsUtils.setPathValue(target, "appearance.header.padding.top", SettingsUtils.clamp(parsedTop, 0, 36));
        SettingsUtils.setPathValue(target, "appearance.header.padding.right", SettingsUtils.clamp(parsedRight, 0, 36));
        SettingsUtils.setPathValue(target, "appearance.header.padding.bottom", SettingsUtils.clamp(parsedBottom, 0, 36));
        SettingsUtils.setPathValue(target, "appearance.header.padding.left", SettingsUtils.clamp(parsedLeft, 0, 36));
    }
}
