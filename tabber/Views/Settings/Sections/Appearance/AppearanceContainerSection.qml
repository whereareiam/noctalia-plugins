import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var appearanceForm
    required property var containerForm

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.title", "Container");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.width.label", "Container width");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.width.description", "Minimum switcher width in pixels. Set 0 to keep automatic width.");
        }
        text: root.containerForm.width
        onTextChanged: root.containerForm.width = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.label", "Container padding");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.description", "Inner padding around the header and cards between 8 and 48.");
        }
        text: root.containerForm.paddingTop
        visible: root.containerForm.paddingLinked
        onTextChanged: root.containerForm.setPaddingValue("top", text)
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.linked.label", "Link container padding sides");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.linked.description", "When enabled, changing one container padding value updates all four sides.");
        }
        checked: root.containerForm.paddingLinked
        onToggled: checked => root.containerForm.setPaddingLinked(checked)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.containerForm.paddingLinked
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.top.label", "Top padding");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.description", "Padding per side in pixels.");
        }
        text: root.containerForm.paddingTop
        onTextChanged: root.containerForm.setPaddingValue("top", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.containerForm.paddingLinked
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.right.label", "Right padding");
        }
        text: root.containerForm.paddingRight
        onTextChanged: root.containerForm.setPaddingValue("right", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.containerForm.paddingLinked
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.bottom.label", "Bottom padding");
        }
        text: root.containerForm.paddingBottom
        onTextChanged: root.containerForm.setPaddingValue("bottom", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.containerForm.paddingLinked
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.padding.left.label", "Left padding");
        }
        text: root.containerForm.paddingLeft
        onTextChanged: root.containerForm.setPaddingValue("left", text)
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.dimOpacity.label", "Dim opacity");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.container.dimOpacity.description", "Background dim amount between 0.10 and 0.85.");
        }
        text: root.appearanceForm.dimOpacity
        onTextChanged: root.appearanceForm.dimOpacity = text
    }
}
