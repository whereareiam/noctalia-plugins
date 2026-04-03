import QtQuick

import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property string width: settings ? String(settings.width) : "0"
    property bool paddingLinked: settings ? settings.paddingLinked : true
    property string paddingTop: settings ? String(settings.paddingTop) : "18"
    property string paddingRight: settings ? String(settings.paddingRight) : "18"
    property string paddingBottom: settings ? String(settings.paddingBottom) : "18"
    property string paddingLeft: settings ? String(settings.paddingLeft) : "18"

    function reset() {
        width = String(settings.width);
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
        var parsedWidth = parseInt(width);
        if (Number.isNaN(parsedWidth)) {
            parsedWidth = settings.width;
        }

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
                                    "containerWidth",
                                    "containerPadding",
                                    "containerPaddingLinked",
                                    "containerPaddingTop",
                                    "containerPaddingRight",
                                    "containerPaddingBottom",
                                    "containerPaddingLeft"
                                ]);
        SettingsUtils.setPathValue(target, "appearance.container.width", parsedWidth <= 0 ? 0 : SettingsUtils.clamp(parsedWidth, 320, 2200));
        SettingsUtils.setPathValue(target, "appearance.container.padding.linked", paddingLinked);
        SettingsUtils.setPathValue(target, "appearance.container.padding.top", SettingsUtils.clamp(parsedTop, 8, 48));
        SettingsUtils.setPathValue(target, "appearance.container.padding.right", SettingsUtils.clamp(parsedRight, 8, 48));
        SettingsUtils.setPathValue(target, "appearance.container.padding.bottom", SettingsUtils.clamp(parsedBottom, 8, 48));
        SettingsUtils.setPathValue(target, "appearance.container.padding.left", SettingsUtils.clamp(parsedLeft, 8, 48));
    }
}
