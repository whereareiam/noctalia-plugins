.pragma library

function resolveScriptPath(pluginApi, rawPath) {
  var path = String(rawPath || "").trim();
  if (!path) {
    return "";
  }
  if (path.startsWith("/")) {
    return path;
  }
  return pluginApi ? pluginApi.pluginDir + "/" + path : path;
}

function basename(path) {
  var normalized = String(path || "").trim();
  if (!normalized) {
    return "";
  }

  var parts = normalized.split("/");
  return parts.length > 0 ? parts[parts.length - 1] : normalized;
}

function stripExtension(filename) {
  return String(filename || "").replace(/\.[^.]+$/, "");
}

function humanizeIdentifier(value) {
  var text = String(value || "").trim();
  if (!text) {
    return "";
  }

  text = text
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  if (!text) {
    return "";
  }

  return text.replace(/\b([a-z])/g, function(match, char) {
    return char.toUpperCase();
  });
}

function normalizeAction(action, index) {
  var normalized = action || ({});
  var overlayKeybind = normalized.overlayKeybind;
  if ((overlayKeybind === undefined || overlayKeybind === null || overlayKeybind === "") && normalized.keybind !== undefined && normalized.keybind !== null) {
    overlayKeybind = normalized.keybind;
  }

  return {
    id: String(normalized.id || ("action-" + index)),
    label: String(normalized.label || ""),
    overlayKeybind: String(overlayKeybind || ""),
    script: String(normalized.script || "")
  };
}

function cloneActions(actions) {
  return JSON.parse(JSON.stringify(actions || []));
}

function makeActionId() {
  return "action-" + Date.now() + "-" + Math.floor(Math.random() * 100000);
}

function actionDisplayName(action, index) {
  var normalized = normalizeAction(action, index);
  var configuredLabel = String(normalized.label || "").trim();
  if (configuredLabel) {
    return configuredLabel;
  }

  var scriptLabel = humanizeIdentifier(stripExtension(basename(normalized.script)));
  if (scriptLabel) {
    return scriptLabel;
  }

  var idLabel = humanizeIdentifier(normalized.id);
  if (idLabel) {
    return idLabel;
  }

  return "Custom Action " + (index + 1);
}

function tabberActionDisplayName(action, index) {
  return "Tabber " + actionDisplayName(action, index);
}

function shortcutNameSegment(action, index) {
  var normalized = normalizeAction(action, index);

  var source = String(normalized.id || "").trim() || stripExtension(basename(normalized.script));
  var slug = String(source || "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

  if (!slug) {
    slug = "custom-action";
  }

  return slug + "-" + (index + 1);
}

function firstActionSource(configuredActions, defaultActions) {
  if (Array.isArray(configuredActions)) {
    return configuredActions;
  }
  if (Array.isArray(defaultActions) && defaultActions.length > 0) {
    return defaultActions;
  }
  return [];
}

function resolveConfiguredActions(pluginApi, configuredActions, defaultActions) {
  var source = firstActionSource(configuredActions, defaultActions);
  var actions = [];
  for (var i = 0; i < source.length; i++) {
    var action = normalizeAction(source[i], i);
    var scriptPath = resolveScriptPath(pluginApi, action.script);
    if (!scriptPath) {
      continue;
    }

    actions.push({
      id: action.id,
      label: action.label,
      overlayKeybind: action.overlayKeybind,
      script: scriptPath
    });
  }
  return actions;
}
