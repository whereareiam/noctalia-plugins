import QtQuick

import "../../../Utils/ActionUtils.js" as ActionUtils
import "../../../Utils/SettingsUtils.js" as SettingsUtils

QtObject {
    id: root

    required property var settings

    property var items: settings ? ActionUtils.cloneActions(settings.effectiveActionSource) : []

    function reset() {
        items = ActionUtils.cloneActions(settings.effectiveActionSource);
    }

    function addAction() {
        var next = ActionUtils.cloneActions(items);
        next.push({
            id: ActionUtils.makeActionId(),
            label: "",
            overlayKeybind: "",
            script: ""
        });
        items = next;
    }

    function removeAction(index) {
        var next = ActionUtils.cloneActions(items);
        if (index >= 0 && index < next.length) {
            next.splice(index, 1);
            items = next;
        }
    }

    function updateActionField(index, field, value) {
        var next = ActionUtils.cloneActions(items);
        if (index >= 0 && index < next.length) {
            next[index][field] = value;
            items = next;
        }
    }

    function updateActionOverlayKeybind(index, newKeybinds) {
        updateActionField(index, "overlayKeybind", (newKeybinds && newKeybinds.length > 0) ? newKeybinds[0] : "");
    }

    function persist(target) {
        var normalizedActions = [];
        for (var i = 0; i < items.length; i++) {
            var normalized = ActionUtils.normalizeAction(items[i], i);
            if (normalized.script.trim() === "") {
                continue;
            }
            normalizedActions.push(normalized);
        }

        SettingsUtils.clearPaths(target, ["actions"]);
        SettingsUtils.setPathValue(target, "actions.items", normalizedActions);
    }
}
