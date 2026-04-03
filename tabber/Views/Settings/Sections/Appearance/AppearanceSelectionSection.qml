import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var selectionForm

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.title", "Selection");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.cardSize.label", "Card size");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.cardSize.description", "Base icon-card size between 64 and 128.");
        }
        text: root.selectionForm.cardSize
        onTextChanged: root.selectionForm.cardSize = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.iconSize.label", "Icon size");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.iconSize.description", "Icon size inside each card between 24 and 96.");
        }
        text: root.selectionForm.iconSize
        onTextChanged: root.selectionForm.iconSize = text
    }

    NTextInput {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.cardGap.label", "Card gap");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.cardGap.description", "Spacing between cards and title slots between 0 and 48.");
        }
        text: root.selectionForm.cardGap
        onTextChanged: root.selectionForm.cardGap = text
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.titleVisibility.label", "Window title visibility");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.titleVisibility.description", "Choose when window titles are shown below the cards.");
        }
        model: [
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleVisibility.options.selected", "Selected only"),
                key: "selected"
            },
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleVisibility.options.all", "All cards"),
                key: "all"
            },
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleVisibility.options.hidden", "Hidden"),
                key: "hidden"
            }
        ]
        currentKey: root.selectionForm.titleVisibility
        onSelected: key => root.selectionForm.titleVisibility = key
    }

    NComboBox {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.titleTruncationMode.label", "Title truncation mode");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.selection.titleTruncationMode.description", "How long titles are shortened when there is not enough space.");
        }
        model: [
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleTruncationMode.options.end", "End ellipsis"),
                key: "end"
            },
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleTruncationMode.options.middle", "Middle ellipsis"),
                key: "middle"
            },
            {
                name: root.settingsStore.tr("settings.appearance.selection.titleTruncationMode.options.twoLines", "Two lines"),
                key: "two-lines"
            }
        ]
        currentKey: root.selectionForm.titleTruncationMode
        enabled: root.selectionForm.titleVisibility !== "hidden"
        opacity: enabled ? 1.0 : 0.5
        onSelected: key => root.selectionForm.titleTruncationMode = key
    }
}
