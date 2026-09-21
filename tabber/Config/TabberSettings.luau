--!nonstrict

local Constants = require("../Core/Constants.luau")
local Settings = {}

function Settings.get(key, fallback)
  local value = noctalia.getConfig(key)
  return value == nil and fallback or value
end

function Settings.readAll()
  return {
    groupWindowsByApp = noctalia.getConfig("group_windows_by_app"),
    enterGroupedWindowSelection = noctalia.getConfig("enter_grouped_window_selection"),
    restrictToCurrentMonitor = noctalia.getConfig("restrict_to_current_monitor"),
    requirePointerMovement = noctalia.getConfig("require_pointer_movement_for_hover_selection"),
    cycleWhileHoldingTab = noctalia.getConfig("cycle_selection_while_holding_tab"),
    stopCycleAtEdge = noctalia.getConfig("stop_continuous_cycle_at_edge"),
    showHeader = noctalia.getConfig("show_header"),
    headerAlignment = noctalia.getConfig("header_alignment"),
    headerText = noctalia.getConfig("header_text"),
    showWindowCount = noctalia.getConfig("show_window_count"),
    headerPaddingLinked = noctalia.getConfig("header_padding_linked"),
    headerPaddingTop = noctalia.getConfig("header_padding_top"),
    headerPaddingRight = noctalia.getConfig("header_padding_right"),
    headerPaddingBottom = noctalia.getConfig("header_padding_bottom"),
    headerPaddingLeft = noctalia.getConfig("header_padding_left"),
    containerWidth = noctalia.getConfig("container_width"),
    containerPaddingTop = noctalia.getConfig("container_padding_top"),
    containerPaddingRight = noctalia.getConfig("container_padding_right"),
    containerPaddingBottom = noctalia.getConfig("container_padding_bottom"),
    containerPaddingLeft = noctalia.getConfig("container_padding_left"),
    cardSize = noctalia.getConfig("card_size"),
    cardGap = noctalia.getConfig("card_gap"),
    iconSize = noctalia.getConfig("icon_size"),
    titleVisibility = noctalia.getConfig("title_visibility"),
    titleTruncationMode = noctalia.getConfig("title_truncation_mode"),
    dimOpacity = noctalia.getConfig("dim_opacity"),
    veilIntegration = noctalia.getConfig("veil_integration"),
    highlightHiddenCards = noctalia.getConfig("highlight_hidden_cards"),
    hiddenCardColor = noctalia.getConfig("hidden_card_color"),
  }
end

function Settings.windowCatalogOptions()
  return {
    groupWindowsByApp = Settings.get(Constants.Setting.GroupWindowsByApp, true) == true,
    restrictToCurrentMonitor = Settings.get(Constants.Setting.RestrictToCurrentMonitor, false) == true,
    focusedOutput = "",
    iconSize = tonumber(Settings.get(Constants.Setting.IconSize, 64)) or 64,
    veilEnabled = Settings.get(Constants.Setting.VeilEnabled, true) == true,
    veilHighlight = Settings.get(Constants.Setting.VeilHighlight, true) == true,
    veilAccent = tostring(Settings.get(Constants.Setting.VeilAccent, "") or ""),
  }
end

return Settings
