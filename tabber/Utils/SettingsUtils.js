.pragma library

function defaultsFromPlugin(pluginApi) {
  if (!pluginApi || !pluginApi.manifest || !pluginApi.manifest.metadata) {
    return ({});
  }
  return pluginApi.manifest.metadata.defaultSettings || ({});
}

function settingValue(pluginApi, defaults, name) {
  if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings[name] !== undefined && pluginApi.pluginSettings[name] !== null) {
    return pluginApi.pluginSettings[name];
  }
  if (defaults && defaults[name] !== undefined && defaults[name] !== null) {
    return defaults[name];
  }
  return undefined;
}

function settingString(pluginApi, defaults, name, fallback) {
  var value = settingValue(pluginApi, defaults, name);
  if (value === undefined || value === null || value === "") {
    return fallback;
  }
  return String(value);
}

function settingBool(pluginApi, defaults, name, fallback) {
  var value = settingValue(pluginApi, defaults, name);
  if (value === undefined || value === null) {
    return fallback;
  }
  return !!value;
}

function settingNumber(pluginApi, defaults, name, fallback) {
  var value = settingValue(pluginApi, defaults, name);
  if (value === undefined || value === null || Number.isNaN(Number(value))) {
    return fallback;
  }
  return Number(value);
}

function clamp(value, minValue, maxValue) {
  return Math.max(minValue, Math.min(maxValue, value));
}
