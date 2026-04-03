import QtQuick

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
}
