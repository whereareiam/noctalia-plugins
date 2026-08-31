import QtQuick
import QtQuick.Layouts

import "../Header" as HeaderComponents
import "../Selection" as SelectionComponents
import qs.Commons
import qs.Widgets

Item {
    id: root

    required property var settingsStore
    required property var appearanceSettings
    required property var selectedGroup
    property string selectedGroupId: ""
    property var displayGroups: []
    property bool hoverSelectionEnabled: true

    signal groupHovered(string groupId)

    signal groupActivated(string groupId)

    readonly property int containerPaddingTopPx: Math.round(Number(root.appearanceSettings.container.paddingTop || 0) * Style.uiScaleRatio)
    readonly property int containerPaddingRightPx: Math.round(Number(root.appearanceSettings.container.paddingRight || 0) * Style.uiScaleRatio)
    readonly property int containerPaddingBottomPx: Math.round(Number(root.appearanceSettings.container.paddingBottom || 0) * Style.uiScaleRatio)
    readonly property int containerPaddingLeftPx: Math.round(Number(root.appearanceSettings.container.paddingLeft || 0) * Style.uiScaleRatio)
    readonly property int configuredContainerWidth: Number(root.appearanceSettings.container.width || 0) > 0 ? Math.round(Number(root.appearanceSettings.container.width) * Style.uiScaleRatio) : 0
    readonly property int headerPaddingTopPx: Math.round(Number(root.appearanceSettings.header.paddingTop || 0) * Style.uiScaleRatio)
    readonly property int headerPaddingRightPx: Math.round(Number(root.appearanceSettings.header.paddingRight || 0) * Style.uiScaleRatio)
    readonly property int headerPaddingBottomPx: Math.round(Number(root.appearanceSettings.header.paddingBottom || 0) * Style.uiScaleRatio)
    readonly property int headerPaddingLeftPx: Math.round(Number(root.appearanceSettings.header.paddingLeft || 0) * Style.uiScaleRatio)
    readonly property int headerContentWidth: headerLoader.item
        ? Math.ceil(headerLoader.item.implicitWidth) + root.headerPaddingLeftPx + root.headerPaddingRightPx
        : 0
    readonly property int minimumContentWidth: Math.max(root.headerContentWidth, groupStrip.implicitWidth)

    implicitWidth: switcherCard.implicitWidth
    implicitHeight: switcherCard.implicitHeight

    NDropShadow {
        anchors.fill: switcherCard
        source: switcherCard
        autoPaddingEnabled: true
    }

    Rectangle {
        id: switcherCard

        anchors.centerIn: parent
        implicitWidth: unifiedContainer.implicitWidth + Style.margin2XL
        implicitHeight: unifiedContainer.implicitHeight + Style.margin2XL
        width: implicitWidth
        height: implicitHeight
        radius: Style.radiusL
        color: "transparent"
        border.color: "transparent"
        border.width: 0

        Rectangle {
            id: unifiedContainer

            anchors.centerIn: parent
            implicitWidth: Math.max(root.configuredContainerWidth, root.minimumContentWidth) + root.containerPaddingLeftPx + root.containerPaddingRightPx
            implicitHeight: unifiedColumn.implicitHeight + root.containerPaddingTopPx + root.containerPaddingBottomPx
            radius: Style.radiusM
            color: Qt.alpha(Color.mSurface, 0.74)
            border.color: Qt.alpha(Color.mOutline, 0.45)
            border.width: Style.borderS

            ColumnLayout {
                id: unifiedColumn

                anchors.fill: parent
                anchors.leftMargin: root.containerPaddingLeftPx
                anchors.rightMargin: root.containerPaddingRightPx
                anchors.topMargin: root.containerPaddingTopPx
                anchors.bottomMargin: root.containerPaddingBottomPx
                spacing: root.appearanceSettings.header.show ? Style.marginXL : 0

                Loader {
                    id: headerLoader

                    active: root.appearanceSettings.header.show
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: root.headerPaddingLeftPx
                    Layout.rightMargin: root.headerPaddingRightPx
                    Layout.topMargin: root.headerPaddingTopPx
                    Layout.bottomMargin: root.headerPaddingBottomPx

                    sourceComponent: HeaderComponents.SwitcherHeader {
                        title: {
                            root.settingsStore.translationVersion;
                            var configured = String(root.appearanceSettings.header.text || "").trim();
                            return configured !== "" ? configured : root.settingsStore.tr("overlay.title", "Tabber");
                        }
                        headerAlignment: String(root.appearanceSettings.header.alignment || "space-between")
                        showWindowCount: root.appearanceSettings.header.showWindowCount
                        windowCount: root.selectedGroup ? root.selectedGroup.windowCount : 0
                        windowCountText: {
                            root.settingsStore.translationVersion;
                            var count = root.selectedGroup ? root.selectedGroup.windowCount : 0;
                            return root.settingsStore.trp("overlay.windowCount", count, "{count} window", "{count} windows", {
                                                             count: count
                                                         });
                        }
                    }
                }

                SelectionComponents.GroupStrip {
                    id: groupStrip

                    Layout.alignment: Qt.AlignHCenter
                    groups: root.displayGroups
                    selectedGroupId: root.selectedGroupId
                    cardSize: Number(root.appearanceSettings.selection.cardSize || 108)
                    cardGap: Number(root.appearanceSettings.selection.cardGap || 9)
                    iconSize: Number(root.appearanceSettings.selection.iconSize || 64)
                    titleVisibility: String(root.appearanceSettings.selection.titleVisibility || "selected")
                    titleTruncationMode: String(root.appearanceSettings.selection.titleTruncationMode || "end")
                    hoverSelectionEnabled: root.hoverSelectionEnabled
                    onGroupHovered: groupId => root.groupHovered(groupId)
                    onGroupActivated: groupId => root.groupActivated(groupId)
                }
            }
        }
    }
}
