import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var headerForm

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.title", "Header");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.show.label", "Show header");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.show.description", "Show the header row above the switcher cards.");
        }
        checked: root.headerForm.show
        onToggled: checked => root.headerForm.show = checked
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.alignment.label", "Header alignment");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.alignment.description", "How the header title and count are aligned.");
        }
        model: [
            {
                name: root.settingsStore.tr("settings.appearance.header.alignment.options.spaceBetween", "Space between"),
                key: "space-between"
            },
            {
                name: root.settingsStore.tr("settings.appearance.header.alignment.options.left", "Left"),
                key: "left"
            },
            {
                name: root.settingsStore.tr("settings.appearance.header.alignment.options.center", "Center"),
                key: "center"
            }
        ]
        currentKey: root.headerForm.alignment
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        onSelected: key => root.headerForm.alignment = key
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.text.label", "Header text");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.text.description", "Custom text shown in the header when it is enabled.");
        }
        text: root.headerForm.text
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        onTextChanged: root.headerForm.text = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.label", "Header padding");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.description", "Extra padding around the header row between 0 and 36.");
        }
        text: root.headerForm.paddingTop
        enabled: root.headerForm.show
        visible: root.headerForm.paddingLinked
        opacity: enabled ? 1.0 : 0.5
        onTextChanged: root.headerForm.setPaddingValue("top", text)
    }

    NToggle {
        Layout.fillWidth: true
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.linked.label", "Link header padding sides");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.linked.description", "When enabled, changing one header padding value updates all four sides.");
        }
        checked: root.headerForm.paddingLinked
        onToggled: checked => root.headerForm.setPaddingLinked(checked)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.headerForm.paddingLinked
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.top.label", "Top padding");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.description", "Padding per side in pixels.");
        }
        text: root.headerForm.paddingTop
        onTextChanged: root.headerForm.setPaddingValue("top", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.headerForm.paddingLinked
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.right.label", "Right padding");
        }
        text: root.headerForm.paddingRight
        onTextChanged: root.headerForm.setPaddingValue("right", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.headerForm.paddingLinked
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.bottom.label", "Bottom padding");
        }
        text: root.headerForm.paddingBottom
        onTextChanged: root.headerForm.setPaddingValue("bottom", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.headerForm.paddingLinked
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.padding.left.label", "Left padding");
        }
        text: root.headerForm.paddingLeft
        onTextChanged: root.headerForm.setPaddingValue("left", text)
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.showWindowCount.label", "Show window count");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.header.showWindowCount.description", "Display the selected group window count in the header badge.");
        }
        checked: root.headerForm.showWindowCount
        enabled: root.headerForm.show
        opacity: enabled ? 1.0 : 0.5
        onToggled: checked => root.headerForm.showWindowCount = checked
    }
}
