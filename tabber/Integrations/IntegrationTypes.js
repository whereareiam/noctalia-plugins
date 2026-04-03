.pragma library

function normalizeEntry(entry) {
  if (!entry) {
    return null;
  }

  return {
    id: String(entry.id || ""),
    groupId: String(entry.groupId || entry.id || ""),
    appId: String(entry.appId || ""),
    iconSource: entry.iconSource || "",
    primaryWindowId: String(entry.primaryWindowId || ""),
    primaryTitle: String(entry.primaryTitle || ""),
    windowCount: Number(entry.windowCount || 0),
    windows: Array.isArray(entry.windows) ? entry.windows : [],
    hasFocusedWindow: entry.hasFocusedWindow === true,
    selectionCardHighlighted: entry.selectionCardHighlighted === true,
    selectionCardAccentColor: String(entry.selectionCardAccentColor || ""),
    isIntegrationEntry: true,
    integrationId: String(entry.integrationId || ""),
    integrationAction: String(entry.integrationAction || "")
  };
}

function normalizeGroupAction(action, integrationId) {
  if (!action) {
    return null;
  }

  return {
    id: String(action.id || ""),
    label: String(action.label || ""),
    overlayKeybind: String(action.overlayKeybind || ""),
    integrationId: String(action.integrationId || integrationId || "")
  };
}
