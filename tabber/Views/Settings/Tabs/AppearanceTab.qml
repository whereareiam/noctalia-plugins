import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsState

    readonly property var headerAlignmentOptions: [
        {
            name: root.settingsState.tr("settings.appearance.headerAlignment.options.spaceBetween", "Space between"),
            key: "space-between"
        },
        {
            name: root.settingsState.tr("settings.appearance.headerAlignment.options.left", "Left"),
            key: "left"
        },
        {
            name: root.settingsState.tr("settings.appearance.headerAlignment.options.center", "Center"),
            key: "center"
        }
    ]
    readonly property var titleVisibilityOptions: [
        {
            name: root.settingsState.tr("settings.appearance.titleVisibility.options.selected", "Selected only"),
            key: "selected"
        },
        {
            name: root.settingsState.tr("settings.appearance.titleVisibility.options.all", "All cards"),
            key: "all"
        },
        {
            name: root.settingsState.tr("settings.appearance.titleVisibility.options.hidden", "Hidden"),
            key: "hidden"
        }
    ]
    readonly property var titleTruncationOptions: [
        {
            name: root.settingsState.tr("settings.appearance.titleTruncationMode.options.end", "End ellipsis"),
            key: "end"
        },
        {
            name: root.settingsState.tr("settings.appearance.titleTruncationMode.options.middle", "Middle ellipsis"),
            key: "middle"
        },
        {
            name: root.settingsState.tr("settings.appearance.titleTruncationMode.options.twoLines", "Two lines"),
            key: "two-lines"
        }
    ]

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.title", "Appearance");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.sections.container", "Container");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerWidth.label", "Container width");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerWidth.description", "Minimum switcher width in pixels. Set 0 to keep automatic width.");
        }
        text: root.settingsState.editContainerWidth
        onTextChanged: root.settingsState.editContainerWidth = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerPadding.label", "Container padding");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerPadding.description", "Inner padding around the header and cards between 8 and 48.");
        }
        text: root.settingsState.editContainerPaddingTop
        visible: root.settingsState.editContainerPaddingLinked
        onTextChanged: root.settingsState.setContainerPaddingValue("top", text)
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerPaddingLinked.label", "Link container padding sides");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.containerPaddingLinked.description", "When enabled, changing one container padding value updates all four sides.");
        }
        checked: root.settingsState.editContainerPaddingLinked
        onToggled: checked => root.settingsState.setContainerPaddingLinked(checked)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editContainerPaddingLinked
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingTop.label", "Top padding");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.padding.description", "Padding per side in pixels.");
        }
        text: root.settingsState.editContainerPaddingTop
        onTextChanged: root.settingsState.setContainerPaddingValue("top", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editContainerPaddingLinked
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingRight.label", "Right padding");
        }
        text: root.settingsState.editContainerPaddingRight
        onTextChanged: root.settingsState.setContainerPaddingValue("right", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editContainerPaddingLinked
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingBottom.label", "Bottom padding");
        }
        text: root.settingsState.editContainerPaddingBottom
        onTextChanged: root.settingsState.setContainerPaddingValue("bottom", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editContainerPaddingLinked
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingLeft.label", "Left padding");
        }
        text: root.settingsState.editContainerPaddingLeft
        onTextChanged: root.settingsState.setContainerPaddingValue("left", text)
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.dimOpacity.label", "Dim opacity");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.dimOpacity.description", "Background dim amount between 0.10 and 0.85.");
        }
        text: root.settingsState.editDimOpacity
        onTextChanged: root.settingsState.editDimOpacity = text
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.sections.header", "Header");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.showHeader.label", "Show header");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.showHeader.description", "Show the header row above the switcher cards.");
        }
        checked: root.settingsState.editShowHeader
        onToggled: checked => root.settingsState.editShowHeader = checked
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerAlignment.label", "Header alignment");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerAlignment.description", "How the header title and count are aligned.");
        }
        model: root.headerAlignmentOptions
        currentKey: root.settingsState.editHeaderAlignment
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        onSelected: key => root.settingsState.editHeaderAlignment = key
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerText.label", "Header text");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerText.description", "Custom text shown in the header when it is enabled.");
        }
        text: root.settingsState.editHeaderText
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        onTextChanged: root.settingsState.editHeaderText = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerPadding.label", "Header padding");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerPadding.description", "Extra padding around the header row between 0 and 36.");
        }
        text: root.settingsState.editHeaderPaddingTop
        enabled: root.settingsState.editShowHeader
        visible: root.settingsState.editHeaderPaddingLinked
        opacity: enabled ? 1.0 : 0.5
        onTextChanged: root.settingsState.setHeaderPaddingValue("top", text)
    }

    NToggle {
        Layout.fillWidth: true
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerPaddingLinked.label", "Link header padding sides");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.headerPaddingLinked.description", "When enabled, changing one header padding value updates all four sides.");
        }
        checked: root.settingsState.editHeaderPaddingLinked
        onToggled: checked => root.settingsState.setHeaderPaddingLinked(checked)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editHeaderPaddingLinked
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingTop.label", "Top padding");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.padding.description", "Padding per side in pixels.");
        }
        text: root.settingsState.editHeaderPaddingTop
        onTextChanged: root.settingsState.setHeaderPaddingValue("top", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editHeaderPaddingLinked
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingRight.label", "Right padding");
        }
        text: root.settingsState.editHeaderPaddingRight
        onTextChanged: root.settingsState.setHeaderPaddingValue("right", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editHeaderPaddingLinked
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingBottom.label", "Bottom padding");
        }
        text: root.settingsState.editHeaderPaddingBottom
        onTextChanged: root.settingsState.setHeaderPaddingValue("bottom", text)
    }

    NTextInput {
        Layout.fillWidth: true
        visible: !root.settingsState.editHeaderPaddingLinked
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.paddingLeft.label", "Left padding");
        }
        text: root.settingsState.editHeaderPaddingLeft
        onTextChanged: root.settingsState.setHeaderPaddingValue("left", text)
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.showWindowCount.label", "Show window count");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.showWindowCount.description", "Display the selected group window count in the header badge.");
        }
        checked: root.settingsState.editShowWindowCount
        enabled: root.settingsState.editShowHeader
        opacity: enabled ? 1.0 : 0.5
        onToggled: checked => root.settingsState.editShowWindowCount = checked
    }

    NDivider {
        Layout.fillWidth: true
    }

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.sections.selection", "Selection");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.cardSize.label", "Card size");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.cardSize.description", "Base icon-card size between 64 and 128.");
        }
        text: root.settingsState.editCardSize
        onTextChanged: root.settingsState.editCardSize = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.iconSize.label", "Icon size");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.iconSize.description", "Icon size inside each card between 24 and 96.");
        }
        text: root.settingsState.editIconSize
        onTextChanged: root.settingsState.editIconSize = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.cardGap.label", "Card gap");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.cardGap.description", "Spacing between cards and title slots between 0 and 48.");
        }
        text: root.settingsState.editCardGap
        onTextChanged: root.settingsState.editCardGap = text
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.titleVisibility.label", "Window title visibility");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.titleVisibility.description", "Choose when window titles are shown below the cards.");
        }
        model: root.titleVisibilityOptions
        currentKey: root.settingsState.editTitleVisibility
        onSelected: key => root.settingsState.editTitleVisibility = key
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.titleTruncationMode.label", "Title truncation mode");
        }
        description: {
            root.settingsState.translationVersion;
            return root.settingsState.tr("settings.appearance.titleTruncationMode.description", "How long titles are shortened when there is not enough space.");
        }
        model: root.titleTruncationOptions
        currentKey: root.settingsState.editTitleTruncationMode
        enabled: root.settingsState.editTitleVisibility !== "hidden"
        opacity: enabled ? 1.0 : 0.5
        onSelected: key => root.settingsState.editTitleTruncationMode = key
    }
}
