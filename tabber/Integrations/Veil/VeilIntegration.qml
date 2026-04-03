import QtQuick

import "../../Utils/GroupUtils.js" as GroupUtils
import "../IntegrationTypes.js" as IntegrationTypes
import qs.Commons

QtObject {
    id: root

    required property var settingsStore
    required property var pluginState
    required property var hiddenWindowsSource

    readonly property string id: "veil"
    readonly property string title: "Veil"
    readonly property bool enabled: settingsStore && settingsStore.integrations && settingsStore.integrations.veil.enabled === true
    readonly property bool available: pluginState ? pluginState.isAvailable : false
    readonly property bool highlightHiddenCards: settingsStore && settingsStore.integrations && settingsStore.integrations.veil.highlightHiddenCards === true
    readonly property string hiddenCardAccentColor: settingsStore && settingsStore.integrations
        ? String(settingsStore.integrations.veil.hiddenCardAccentColor || "")
        : ""
    readonly property var entries: {
        if (!enabled || !available) {
            return [];
        }

        var sourceEntries = hiddenWindowsSource ? (hiddenWindowsSource.hiddenWindows || []) : [];
        var nextEntries = [];
        for (var index = 0; index < sourceEntries.length; index++) {
            var hiddenEntry = sourceEntries[index];
            var hiddenId = String(hiddenEntry && hiddenEntry.address || "");
            if (!hiddenId) {
                continue;
            }

            nextEntries.push(IntegrationTypes.normalizeEntry({
                id: hiddenId,
                groupId: "integration-" + id + "-" + GroupUtils.normalizeGroupId(hiddenId),
                appId: String(hiddenEntry && hiddenEntry.appId || ""),
                iconSource: ThemeIcons.iconForAppId(String(hiddenEntry && hiddenEntry.appId || "")),
                primaryWindowId: hiddenId,
                primaryTitle: String(hiddenEntry && (hiddenEntry.title || hiddenEntry.appId) || "Hidden window"),
                windowCount: 1,
                selectionCardHighlighted: root.highlightHiddenCards,
                selectionCardAccentColor: root.hiddenCardAccentColor,
                windows: [{
                        id: hiddenId,
                        title: String(hiddenEntry && (hiddenEntry.title || hiddenEntry.appId) || "Hidden window"),
                        appId: String(hiddenEntry && hiddenEntry.appId || ""),
                        workspaceId: String(hiddenEntry && hiddenEntry.workspace || ""),
                        output: String(hiddenEntry && hiddenEntry.output || ""),
                        isFocused: false,
                        width: 0,
                        height: 0,
                        isHidden: true
                    }],
                integrationId: id,
                integrationAction: "restore"
            }));
        }

        return nextEntries;
    }

    function activateEntry(entry) {
        if (!entry || entry.integrationId !== id || !hiddenWindowsSource || !hiddenWindowsSource.restoreWindow) {
            return false;
        }

        hiddenWindowsSource.restoreWindow(entry.primaryWindowId || entry.id || "");
        return true;
    }
}
