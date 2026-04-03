import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var mainInstance: pluginApi ? pluginApi.mainInstance : null
    readonly property int hiddenCount: mainInstance ? mainInstance.hiddenWindowCount : 0
    readonly property string tooltipLabel: {
        if (pluginApi && pluginApi.trp) {
            return pluginApi.trp("bar.tooltip", hiddenCount, {
                                   count: hiddenCount
                               });
        }

        return hiddenCount === 1 ? "1 hidden window" : (hiddenCount + " hidden windows");
    }

    visible: true

    baseSize: Style.getCapsuleHeightForScreen(screen ? screen.name : "")
    applyUiScale: false
    icon: "eye-off"
    tooltipText: tooltipLabel
    tooltipDirection: BarService.getTooltipDirection(screen ? screen.name : "")
    customRadius: Style.radiusL

    colorBg: hiddenCount > 0 ? Qt.alpha(Color.mPrimary, 0.18) : Style.capsuleColor
    colorFg: hiddenCount > 0 ? Color.mPrimary : Color.mOnSurfaceVariant
    colorBgHover: Color.mHover
    colorFgHover: Color.mOnHover
    colorBorder: "transparent"
    colorBorderHover: "transparent"

    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    NPopupContextMenu {
        id: contextMenu

        model: [{
                "label": pluginApi && pluginApi.tr ? pluginApi.tr("bar.menu.open") : "Restore hidden windows",
                "action": "open-restore-menu",
                "icon": "eye"
            }]

        onTriggered: action => {
            contextMenu.close();
            PanelService.closeContextMenu(screen);

            if (action === "open-restore-menu" && pluginApi) {
                pluginApi.openPanel(screen, root);
            }
        }
    }

    onClicked: {
        if (pluginApi) {
            pluginApi.openPanel(screen, root);
        }
    }

    onRightClicked: {
        PanelService.showContextMenu(contextMenu, root, screen);
    }
}
