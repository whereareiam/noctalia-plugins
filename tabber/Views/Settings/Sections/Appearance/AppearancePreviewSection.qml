import QtQuick
import QtQuick.Layouts

import "../../../../Components/Runtime/Overlay" as OverlayComponents
import qs.Commons
import qs.Services.UI
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var generalForm
    required property var appearanceForm
    required property var previewForm

    property string selectedGroupId: ""
    readonly property var previewGroups: root.generalForm.groupWindowsByApp ? groupedPreviewGroups : ungroupedPreviewGroups
    readonly property var selectedGroup: {
        for (var i = 0; i < root.previewGroups.length; i++) {
            if (root.previewGroups[i].groupId === root.selectedGroupId) {
                return root.previewGroups[i];
            }
        }
        return root.previewGroups.length > 0 ? root.previewGroups[0] : null;
    }
    readonly property var groupedPreviewGroups: [
        {
            groupId: "firefox",
            appId: "firefox",
            iconSource: ThemeIcons.iconForAppId("firefox"),
            primaryWindowId: "preview-firefox",
            primaryTitle: "Open tabs - Firefox",
            windowCount: 3,
            windows: [{id: "preview-firefox-1"}, {id: "preview-firefox-2"}, {id: "preview-firefox-3"}]
        },
        {
            groupId: "code",
            appId: "code",
            iconSource: ThemeIcons.iconForAppId("code"),
            primaryWindowId: "preview-code",
            primaryTitle: "noctalia-plugins - Visual Studio Code",
            windowCount: 2,
            windows: [{id: "preview-code-1"}, {id: "preview-code-2"}]
        },
        {
            groupId: "kitty",
            appId: "kitty",
            iconSource: ThemeIcons.iconForAppId("kitty"),
            primaryWindowId: "preview-kitty",
            primaryTitle: "tabber refactor",
            windowCount: 1,
            windows: [{id: "preview-kitty-1"}]
        }
    ]
    readonly property var ungroupedPreviewGroups: [
        {
            groupId: "window-firefox-1",
            appId: "firefox",
            iconSource: ThemeIcons.iconForAppId("firefox"),
            primaryWindowId: "preview-firefox-1",
            primaryTitle: "Open tabs - Firefox",
            windowCount: 1,
            windows: [{id: "preview-firefox-1"}]
        },
        {
            groupId: "window-code-1",
            appId: "code",
            iconSource: ThemeIcons.iconForAppId("code"),
            primaryWindowId: "preview-code-1",
            primaryTitle: "noctalia-plugins - Visual Studio Code",
            windowCount: 1,
            windows: [{id: "preview-code-1"}]
        },
        {
            groupId: "window-kitty-1",
            appId: "kitty",
            iconSource: ThemeIcons.iconForAppId("kitty"),
            primaryWindowId: "preview-kitty-1",
            primaryTitle: "tabber refactor",
            windowCount: 1,
            windows: [{id: "preview-kitty-1"}]
        }
    ]

    function ensureSelection() {
        var exists = false;
        for (var i = 0; i < previewGroups.length; i++) {
            if (previewGroups[i].groupId === selectedGroupId) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            selectedGroupId = previewGroups.length > 1 ? previewGroups[1].groupId : (previewGroups.length > 0 ? previewGroups[0].groupId : "");
        }
    }

    Layout.fillWidth: true
    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    onPreviewGroupsChanged: ensureSelection()
    Component.onCompleted: ensureSelection()

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.preview.title", "Designer preview");
        }
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.preview.enabled.label", "Enable designer preview");
        }
        description: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.preview.enabled.description", "Show a live sample switcher in settings while you tweak the layout. This is intended for design work and screenshots.");
        }
        checked: root.previewForm.enabled
        onToggled: checked => root.previewForm.enabled = checked
    }

    NText {
        Layout.fillWidth: true
        visible: root.previewForm.enabled
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.preview.hint", "The preview uses sample windows and updates from your unsaved draft settings.");
        }
        pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
    }

    Rectangle {
        Layout.fillWidth: true
        visible: root.previewForm.enabled
        radius: Style.radiusL
        color: Qt.alpha(Color.mSurfaceVariant, 0.72)
        border.color: Qt.alpha(Color.mOutline, 0.55)
        border.width: Style.borderS
        implicitHeight: previewSurface.implicitHeight + Style.marginXL * 2

        OverlayComponents.SwitcherSurface {
            id: previewSurface

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            settingsStore: root.settingsStore
            appearanceSettings: root.appearanceForm
            selectedGroup: root.selectedGroup
            selectedGroupId: root.selectedGroupId
            displayGroups: root.previewGroups
            onGroupHovered: groupId => root.selectedGroupId = groupId
            onGroupActivated: groupId => root.selectedGroupId = groupId
        }
    }
}
