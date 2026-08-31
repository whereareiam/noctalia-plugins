--!nonstrict

local Constants = {}

Constants.Plugin = {
  Id = "whereareiam/tabber",
  OverlayPanelId = "whereareiam/tabber:overlay",
  VeilServiceId = "whereareiam/veil:service",
}

Constants.State = {
  View = "tabber.view",
  Command = "tabber.command",
  CommandQueue = "tabber.command-queue",
  SessionId = "sessionId",
}

Constants.Event = {
  Trigger = "trigger",
  Next = "next",
  Previous = "previous",
  TriggerRelease = "trigger-release",
  Release = "release",
  Hide = "hide",
  Accept = "accept",
  EnterGroup = "enter-group",
  Action = "action",
  Close = "close",
  Select = "select",
  Refresh = "refresh",
  Debug = "debug",
  Restore = "restore",
  Toggle = "toggle",
}

Constants.Command = {
  Trigger = "trigger",
  TriggerRelease = "trigger-release",
  Release = "release",
  PanelOpened = "panel-opened",
  Hide = "hide",
  Accept = "accept",
  EnterGroup = "enter-group",
  Select = "select",
  RunAction = "run-action",
}

Constants.Direction = {
  Next = "next",
  Previous = "previous",
}

Constants.Key = {
  Tab = "Tab",
  ShiftTab = "Shift+Tab",
  Escape = "Escape",
  Grave = "Grave",
  AltLeft = "Alt_L",
  AltRight = "Alt_R",
}

Constants.Action = {
  CloseId = "close",
}

Constants.Window = {
  DefaultTitle = "Untitled",
  HiddenTitle = "Hidden window",
  HiddenWorkspace = "special:hidden",
  VeilGroupPrefix = "integration-veil-",
}

Constants.Integration = {
  VeilId = "veil",
  VeilRuntimeDirectory = "veil",
  VeilStateFile = "hidden-windows.json",
  VeilSelectionTargetFile = "selection-target.json",
}

Constants.Setting = {
  GroupWindowsByApp = "group_windows_by_app",
  EnterGroupedWindowSelection = "enter_grouped_window_selection",
  RestrictToCurrentMonitor = "restrict_to_current_monitor",
  RequirePointerMovement = "require_pointer_movement_for_hover_selection",
  CycleWhileHoldingTab = "cycle_selection_while_holding_tab",
  StopCycleAtEdge = "stop_continuous_cycle_at_edge",
  ContainerWidth = "container_width",
  ContainerPaddingTop = "container_padding_top",
  ContainerPaddingRight = "container_padding_right",
  ContainerPaddingBottom = "container_padding_bottom",
  ContainerPaddingLeft = "container_padding_left",
  CardSize = "card_size",
  CardGap = "card_gap",
  IconSize = "icon_size",
  TitleVisibility = "title_visibility",
  TitleTruncation = "title_truncation_mode",
  DimOpacity = "dim_opacity",
  HeaderShow = "show_header",
  HeaderAlignment = "header_alignment",
  HeaderText = "header_text",
  HeaderShowCount = "show_window_count",
  HeaderPaddingLinked = "header_padding_linked",
  HeaderPaddingTop = "header_padding_top",
  HeaderPaddingRight = "header_padding_right",
  HeaderPaddingBottom = "header_padding_bottom",
  HeaderPaddingLeft = "header_padding_left",
  VeilEnabled = "veil_integration",
  VeilHighlight = "highlight_hidden_cards",
  VeilAccent = "hidden_card_color",
}

return Constants
