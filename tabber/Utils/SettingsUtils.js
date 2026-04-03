.pragma library

function defaultsFromPlugin(pluginApi) {
  if (!pluginApi || !pluginApi.manifest || !pluginApi.manifest.metadata) {
    return ({});
  }
  return pluginApi.manifest.metadata.defaultSettings || ({});
}

function normalizePaths(paths) {
  if (Array.isArray(paths)) {
    return paths;
  }
  return [paths];
}

function pathValue(source, path) {
  if (!source || !path) {
    return undefined;
  }

  var segments = String(path).split(".");
  var current = source;
  for (var i = 0; i < segments.length; i++) {
    var segment = segments[i];
    if (!segment || current === undefined || current === null || current[segment] === undefined || current[segment] === null) {
      return undefined;
    }
    current = current[segment];
  }
  return current;
}

function settingValue(pluginApi, defaults, paths) {
  var normalizedPaths = normalizePaths(paths);
  var pluginSettings = pluginApi ? pluginApi.pluginSettings : null;

  for (var i = 0; i < normalizedPaths.length; i++) {
    var pluginValue = pathValue(pluginSettings, normalizedPaths[i]);
    if (pluginValue !== undefined && pluginValue !== null) {
      return pluginValue;
    }
  }

  for (var j = 0; j < normalizedPaths.length; j++) {
    var defaultValue = pathValue(defaults, normalizedPaths[j]);
    if (defaultValue !== undefined && defaultValue !== null) {
      return defaultValue;
    }
  }

  return undefined;
}

function settingString(pluginApi, defaults, paths, fallback) {
  var value = settingValue(pluginApi, defaults, paths);
  if (value === undefined || value === null || value === "") {
    return fallback;
  }
  return String(value);
}

function settingBool(pluginApi, defaults, paths, fallback) {
  var value = settingValue(pluginApi, defaults, paths);
  if (value === undefined || value === null) {
    return fallback;
  }
  return !!value;
}

function settingNumber(pluginApi, defaults, paths, fallback) {
  var value = settingValue(pluginApi, defaults, paths);
  if (value === undefined || value === null || Number.isNaN(Number(value))) {
    return fallback;
  }
  return Number(value);
}

function settingArray(pluginApi, defaults, paths, fallback) {
  var value = settingValue(pluginApi, defaults, paths);
  if (!Array.isArray(value)) {
    return fallback;
  }
  return value;
}

function ensureParentPath(target, path) {
  var segments = String(path).split(".");
  var current = target;
  for (var i = 0; i < segments.length - 1; i++) {
    var segment = segments[i];
    if (!segment) {
      continue;
    }
    if (typeof current[segment] !== "object" || current[segment] === null || Array.isArray(current[segment])) {
      current[segment] = ({});
    }
    current = current[segment];
  }
  return {
    parent: current,
    key: segments[segments.length - 1]
  };
}

function setPathValue(target, path, value) {
  if (!target || !path) {
    return;
  }

  var location = ensureParentPath(target, path);
  location.parent[location.key] = value;
}

function deletePathValue(target, path) {
  if (!target || !path) {
    return;
  }

  var segments = String(path).split(".");
  var stack = [];
  var current = target;

  for (var i = 0; i < segments.length - 1; i++) {
    var segment = segments[i];
    if (!segment || typeof current !== "object" || current === null || current[segment] === undefined || current[segment] === null) {
      return;
    }
    stack.push({
      parent: current,
      key: segment
    });
    current = current[segment];
  }

  if (typeof current !== "object" || current === null) {
    return;
  }

  delete current[segments[segments.length - 1]];

  for (var stackIndex = stack.length - 1; stackIndex >= 0; stackIndex--) {
    var entry = stack[stackIndex];
    var candidate = entry.parent[entry.key];
    if (candidate && typeof candidate === "object" && !Array.isArray(candidate) && Object.keys(candidate).length === 0) {
      delete entry.parent[entry.key];
    } else {
      break;
    }
  }
}

function clearPaths(target, paths) {
  var normalizedPaths = normalizePaths(paths);
  for (var i = 0; i < normalizedPaths.length; i++) {
    deletePathValue(target, normalizedPaths[i]);
  }
}

function clamp(value, minValue, maxValue) {
  return Math.max(minValue, Math.min(maxValue, value));
}

function isHexColorString(value) {
  var normalizedValue = String(value || "").trim();
  return /^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(normalizedValue);
}
