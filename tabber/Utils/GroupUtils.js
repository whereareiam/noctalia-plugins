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
        var preferredCandidate = windows[i];
        if (preferredCandidate.id === preferredWindowId && preferredCandidate.isHidden !== true) {
            return preferredCandidate;
        }
    }

    for (var i = 0; i < windows.length; i++) {
        var candidate = windows[i];
        if (candidate.isFocused && candidate.isHidden !== true) {
            return candidate;
        }
    }

    for (var i = 0; i < windows.length; i++) {
        var visibleCandidate = windows[i];
        if (visibleCandidate.isHidden !== true) {
            return visibleCandidate;
        }
    }

    for (var i = 0; i < windows.length; i++) {
        var hiddenPreferredCandidate = windows[i];
        if (hiddenPreferredCandidate.id === preferredWindowId) {
            return hiddenPreferredCandidate;
        }
    }

    return windows.length > 0 ? windows[0] : null;
}
