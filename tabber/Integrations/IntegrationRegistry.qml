import QtQuick
import "./IntegrationTypes.js" as IntegrationTypes

QtObject {
    id: root

    property var providers: []

    readonly property var entries: {
        var nextEntries = [];
        for (var index = 0; index < providers.length; index++) {
            var provider = providers[index];
            if (!provider || provider.enabled !== true || provider.available !== true || !provider.entries) {
                continue;
            }

            for (var entryIndex = 0; entryIndex < provider.entries.length; entryIndex++) {
                nextEntries.push(provider.entries[entryIndex]);
            }
        }
        return nextEntries;
    }

    function providerById(providerId) {
        for (var index = 0; index < providers.length; index++) {
            var provider = providers[index];
            if (provider && provider.id === providerId) {
                return provider;
            }
        }

        return null;
    }

    function activateEntry(entry) {
        if (!entry || !entry.integrationId) {
            return false;
        }

        var provider = providerById(entry.integrationId);
        if (!provider || !provider.activateEntry) {
            return false;
        }

        return provider.activateEntry(entry);
    }

    function groupActionsFor(groupData) {
        var nextActions = [];
        for (var index = 0; index < providers.length; index++) {
            var provider = providers[index];
            if (!provider || provider.enabled !== true || provider.available !== true || !provider.groupActionsFor) {
                continue;
            }

            var providerActions = provider.groupActionsFor(groupData);
            if (!providerActions || !providerActions.length) {
                continue;
            }

            for (var actionIndex = 0; actionIndex < providerActions.length; actionIndex++) {
                var normalizedAction = IntegrationTypes.normalizeGroupAction(providerActions[actionIndex], provider.id);
                if (normalizedAction && normalizedAction.id && normalizedAction.overlayKeybind) {
                    nextActions.push(normalizedAction);
                }
            }
        }

        return nextActions;
    }

    function findGroupActionByOverlayKeybind(groupData, overlayKeybind) {
        var normalizedKeybind = String(overlayKeybind || "").trim();
        if (!normalizedKeybind) {
            return null;
        }

        var availableActions = groupActionsFor(groupData);
        for (var index = 0; index < availableActions.length; index++) {
            if (availableActions[index].overlayKeybind === normalizedKeybind) {
                return availableActions[index];
            }
        }

        return null;
    }

    function runGroupAction(action, groupData, context) {
        if (!action || !action.integrationId) {
            return false;
        }

        var provider = providerById(action.integrationId);
        if (!provider || !provider.runGroupAction) {
            return false;
        }

        return provider.runGroupAction(action, groupData, context || ({}));
    }

    function syncSelectionTarget(groupData, context) {
        var nextContext = context || ({});
        for (var index = 0; index < providers.length; index++) {
            var provider = providers[index];
            if (!provider || provider.enabled !== true || provider.available !== true || !provider.syncSelectionTarget) {
                continue;
            }

            provider.syncSelectionTarget(groupData, nextContext);
        }
    }
}
