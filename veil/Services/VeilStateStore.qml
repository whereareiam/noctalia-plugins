import QtQuick
import Quickshell
import Quickshell.Io

import "../Utils/HiddenStateUtils.js" as HiddenStateUtils

Item {
    id: root

    required property var hiddenWindowsModel

    visible: false
    property bool loaded: false
    readonly property string runtimeDir: {
        var detectedRuntimeDir = Quickshell.env("XDG_RUNTIME_DIR");
        var uid = Quickshell.env("UID");
        if (!detectedRuntimeDir && uid) {
            detectedRuntimeDir = "/run/user/" + uid;
        }
        return detectedRuntimeDir || "";
    }
    readonly property string cacheDir: runtimeDir ? (runtimeDir + "/veil") : ""
    readonly property string statePath: cacheDir ? (cacheDir + "/hidden-windows.json") : ""

    function loadState(text) {
        hiddenWindowsModel.setWindows(HiddenStateUtils.parseState(text));
        loaded = true;
    }

    function save() {
        var jsonText = HiddenStateUtils.stateJson(hiddenWindowsModel.windows);
        if (!statePath) {
            return;
        }

        var escapedDir = HiddenStateUtils.escapeForShell(cacheDir);
        var escapedPath = HiddenStateUtils.escapeForShell(statePath);
        var escapedJson = HiddenStateUtils.escapeForShell(jsonText);
        Quickshell.execDetached([
            "sh",
            "-c",
            "mkdir -p '" + escapedDir + "' && printf '%s' '" + escapedJson + "' > '" + escapedPath + "'"
        ]);
    }

    FileView {
        path: root.statePath || undefined
        printErrors: false
        watchChanges: true

        onLoaded: {
            root.loadState(text());
        }

        onFileChanged: reload()

        onLoadFailed: {
            root.hiddenWindowsModel.setWindows([]);
            root.loaded = true;
        }
    }
}
