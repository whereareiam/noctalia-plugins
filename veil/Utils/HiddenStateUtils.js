.pragma library

function normalizeAddress(address) {
  var normalized = String(address || "").trim().toLowerCase();
  if (!normalized) {
    return "";
  }

  return normalized.indexOf("0x") === 0 ? normalized : ("0x" + normalized);
}

function normalizeEntry(entry) {
  var normalizedAddress = normalizeAddress(entry && entry.address);
  if (!normalizedAddress) {
    return null;
  }

  return {
    address: normalizedAddress,
    appId: String(entry && entry.appId || ""),
    title: String(entry && entry.title || ""),
    workspace: String(entry && entry.workspace || ""),
    output: String(entry && entry.output || ""),
    hiddenAt: Number(entry && entry.hiddenAt || Date.now())
  };
}

function sortEntries(entries) {
  var normalizedEntries = [];
  var seenAddresses = ({});

  for (var i = 0; i < (entries || []).length; i++) {
    var normalizedEntry = normalizeEntry(entries[i]);
    if (!normalizedEntry || seenAddresses[normalizedEntry.address]) {
      continue;
    }

    normalizedEntries.push(normalizedEntry);
    seenAddresses[normalizedEntry.address] = true;
  }

  normalizedEntries.sort(function (left, right) {
    return Number(right.hiddenAt || 0) - Number(left.hiddenAt || 0);
  });

  return normalizedEntries;
}

function parseState(text) {
  if (!text || String(text).trim() === "") {
    return [];
  }

  try {
    var parsed = JSON.parse(text);
    if (Array.isArray(parsed)) {
      return sortEntries(parsed);
    }

    if (parsed && Array.isArray(parsed.windows)) {
      return sortEntries(parsed.windows);
    }
  } catch (e) {
  }

  return [];
}

function stateObject(entries) {
  return {
    version: 1,
    windows: sortEntries(entries)
  };
}

function stateJson(entries) {
  return JSON.stringify(stateObject(entries));
}

function escapeForShell(text) {
  return String(text || "").replace(/'/g, "'\"'\"'");
}
