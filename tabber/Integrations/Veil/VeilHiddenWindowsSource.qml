import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    required property var veilPluginState

    property var hiddenWindows: []
    readonly property string runtimeDir: {
        var detectedRuntimeDir = Quickshell.env("XDG_RUNTIME_DIR");
        var uid = Quickshell.env("UID");
        if (!detectedRuntimeDir && uid) {
            detectedRuntimeDir = "/run/user/" + uid;
        }
        return detectedRuntimeDir || "";
    }
    readonly property string statePath: runtimeDir ? (runtimeDir + "/veil/hidden-windows.json") : ""

    function normalizeAddress(address) {
        var normalized = String(address || "").trim().toLowerCase();
        if (!normalized) {
            return "";
        }

        return normalized.indexOf("0x") === 0 ? normalized : ("0x" + normalized);
    }

    function loadState(text) {
        if (!veilPluginState || !veilPluginState.isAvailable) {
            hiddenWindows = [];
            return;
        }

        if (!text || String(text).trim() === "") {
            hiddenWindows = [];
            return;
        }

        try {
            var parsed = JSON.parse(text);
            var sourceWindows = Array.isArray(parsed) ? parsed : (parsed && Array.isArray(parsed.windows) ? parsed.windows : []);
            var nextWindows = [];

            for (var index = 0; index < sourceWindows.length; index++) {
                var candidate = sourceWindows[index];
                var normalizedAddress = normalizeAddress(candidate && candidate.address);
                if (!normalizedAddress) {
                    continue;
                }

                nextWindows.push({
                    address: normalizedAddress,
                    appId: String(candidate && candidate.appId || candidate && candidate.app_id || ""),
                    title: String(candidate && candidate.title || ""),
                    workspace: String(candidate && candidate.workspace || ""),
                    output: String(candidate && candidate.output || ""),
                    hiddenAt: Number(candidate && candidate.hiddenAt || 0)
                });
            }

            nextWindows.sort(function (left, right) {
                return Number(right.hiddenAt || 0) - Number(left.hiddenAt || 0);
            });
            hiddenWindows = nextWindows;
        } catch (e) {
            hiddenWindows = [];
        }
    }

    function restoreWindow(address) {
        if (!veilPluginState || !veilPluginState.isAvailable) {
            return;
        }

        var normalizedAddress = normalizeAddress(address);
        if (!normalizedAddress) {
            return;
        }

        Quickshell.execDetached(["qs", "ipc", "-c", "noctalia-shell", "call", "plugin:veil", "restore", normalizedAddress]);
    }

    function hideWindow(address) {
        if (!veilPluginState || !veilPluginState.isAvailable) {
            return;
        }

        var normalizedAddress = normalizeAddress(address);
        if (!normalizedAddress) {
            return;
        }

        Quickshell.execDetached(["qs", "ipc", "-c", "noctalia-shell", "call", "plugin:veil", "hide", normalizedAddress]);
    }

    property FileView stateFile: FileView {
        path: root.statePath || undefined
        printErrors: false
        watchChanges: true

        onLoaded: root.loadState(text())

        onFileChanged: reload()

        onLoadFailed: root.hiddenWindows = []
    }

    property Connections availabilityConnections: Connections {
        target: root.veilPluginState

        function onIsAvailableChanged() {
            if (!root.veilPluginState.isAvailable) {
                root.hiddenWindows = [];
            } else {
                root.stateFile.reload();
            }
        }
    }
}
