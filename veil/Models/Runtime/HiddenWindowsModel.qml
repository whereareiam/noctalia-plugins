import QtQuick

import "../../Utils/HiddenStateUtils.js" as HiddenStateUtils

QtObject {
    id: root

    property var windows: []
    readonly property int hiddenCount: windows.length

    function setWindows(nextWindows) {
        windows = HiddenStateUtils.sortEntries(nextWindows || []);
    }

    function entryByAddress(address) {
        var normalizedAddress = HiddenStateUtils.normalizeAddress(address);
        if (!normalizedAddress) {
            return null;
        }

        for (var index = 0; index < windows.length; index++) {
            if (windows[index] && windows[index].address === normalizedAddress) {
                return windows[index];
            }
        }

        return null;
    }

    function containsAddress(address) {
        return entryByAddress(address) !== null;
    }

    function upsertWindow(entry) {
        var normalizedEntry = HiddenStateUtils.normalizeEntry(entry);
        if (!normalizedEntry) {
            return;
        }

        var nextWindows = windows.slice();
        var replaced = false;
        for (var index = 0; index < nextWindows.length; index++) {
            if (nextWindows[index] && nextWindows[index].address === normalizedEntry.address) {
                nextWindows[index] = normalizedEntry;
                replaced = true;
                break;
            }
        }

        if (!replaced) {
            nextWindows.push(normalizedEntry);
        }

        setWindows(nextWindows);
    }

    function removeWindow(address) {
        var normalizedAddress = HiddenStateUtils.normalizeAddress(address);
        if (!normalizedAddress) {
            return;
        }

        setWindows(windows.filter(function (entry) {
            return entry && entry.address !== normalizedAddress;
        }));
    }
}
