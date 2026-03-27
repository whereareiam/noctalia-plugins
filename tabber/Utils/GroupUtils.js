.pragma library

function normalizeGroupId(value) {
    var key = String(value || "").trim().toLowerCase();
    if (!key) {
        return "unknown";
    }
    return key.replace(/[^a-z0-9._-]+/g, "-");
}

function isSpecialWorkspaceId(value) {
    var workspaceId = Number(value);
    return !Number.isNaN(workspaceId) && workspaceId < 0;
}

function choosePreferredWindow(windows, preferredWindowId) {
    for (var i = 0; i < windows.length; i++) {
        var candidate = windows[i];
        if (candidate.id === preferredWindowId || candidate.isFocused) {
            return candidate;
        }
    }

    return windows.length > 0 ? windows[0] : null;
}
