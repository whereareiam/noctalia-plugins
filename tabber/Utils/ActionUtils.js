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

function createSeedActions(closeKeybind, closeScript, hideKeybind, hideScript) {
  return [
    {
      id: "close",
      keybind: String(closeKeybind || ""),
      script: String(closeScript || "")
    },
    {
      id: "hide",
      keybind: String(hideKeybind || ""),
      script: String(hideScript || "")
    }
  ];
}

function normalizeAction(action, index) {
  var normalized = action || ({});
  return {
    id: String(normalized.id || ("action-" + index)),
    keybind: String(normalized.keybind || ""),
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

  if (normalized.id === "close") {
    return "Close Selected Group";
  }
  if (normalized.id === "hide") {
    return "Hide Selected Group";
  }

  var scriptLabel = humanizeIdentifier(stripExtension(basename(normalized.script)));
  if (scriptLabel) {
    return scriptLabel;
  }

  return "Custom Action " + (index + 1);
}

function tabberActionDisplayName(action, index) {
  return "Tabber " + actionDisplayName(action, index);
}

function shortcutNameSegment(action, index) {
  var normalized = normalizeAction(action, index);

  if (normalized.id === "close" || normalized.id === "hide") {
    return normalized.id;
  }

  var source = stripExtension(basename(normalized.script));
  var slug = String(source || "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

  if (!slug) {
    slug = "custom-action";
  }

  return slug + "-" + (index + 1);
}

function firstActionSource(configuredActions, defaultActions, seedActions) {
  if (Array.isArray(configuredActions)) {
    return configuredActions;
  }
  if (Array.isArray(defaultActions) && defaultActions.length > 0) {
    return defaultActions;
  }
  return seedActions || [];
}

function resolveConfiguredActions(pluginApi, configuredActions, defaultActions, seedActions) {
  var source = firstActionSource(configuredActions, defaultActions, seedActions);
  var actions = [];
  for (var i = 0; i < source.length; i++) {
    var action = normalizeAction(source[i], i);
    var scriptPath = resolveScriptPath(pluginApi, action.script);
    if (!scriptPath) {
      continue;
    }

    actions.push({
      id: action.id,
      keybind: action.keybind,
      script: scriptPath
    });
  }
  return actions;
}
