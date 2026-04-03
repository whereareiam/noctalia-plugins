import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    readonly property string runtimeDir: {
        var detectedRuntimeDir = Quickshell.env("XDG_RUNTIME_DIR");
        var uid = Quickshell.env("UID");
        if (!detectedRuntimeDir && uid) {
            detectedRuntimeDir = "/run/user/" + uid;
        }
        return detectedRuntimeDir || "";
    }
    readonly property string pluginsStatePath: Quickshell.env("HOME") ? (Quickshell.env("HOME") + "/.config/noctalia/plugins.json") : ""
    property bool isInstalled: false
    property bool isEnabled: false
    readonly property bool isAvailable: isInstalled && isEnabled
    readonly property string effectivePluginId: {
        if (isEnabled && enabledPluginId) {
            return enabledPluginId;
        }
        if (installedPluginId) {
            return installedPluginId;
        }
        return "";
    }
    property string installedPluginId: ""
    property string enabledPluginId: ""

    function loadState(text) {
        installedPluginId = "";
        enabledPluginId = "";
        isInstalled = false;
        isEnabled = false;

        if (!text || String(text).trim() === "") {
            return;
        }

        try {
            var parsed = JSON.parse(text);
            var states = parsed && parsed.states ? parsed.states : ({});
            var candidateIds = ["fbd272:veil", "veil"];

            for (var index = 0; index < candidateIds.length; index++) {
                var candidateId = candidateIds[index];
                if (states[candidateId] !== undefined) {
                    installedPluginId = candidateId;
                    isInstalled = true;
                    if (states[candidateId] && states[candidateId].enabled === true) {
                        enabledPluginId = candidateId;
                        isEnabled = true;
                        break;
                    }
                }
            }
        } catch (e) {
            isInstalled = false;
            isEnabled = false;
        }
    }

    property FileView pluginsStateFile: FileView {
        path: root.pluginsStatePath || undefined
        printErrors: false
        watchChanges: true

        onLoaded: root.loadState(text())

        onFileChanged: reload()

        onLoadFailed: {
            root.installedPluginId = "";
            root.enabledPluginId = "";
            root.isInstalled = false;
            root.isEnabled = false;
        }
    }
}
