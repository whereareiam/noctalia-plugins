--!nonstrict

local Constants = {}

Constants.Plugin = {
  Id = "whereareiam/veil",
  RestorePanelId = "whereareiam/veil:restore",
}

Constants.State = {
  Hidden = "hidden",
  Command = "command",
}

Constants.Event = {
  ToggleFocused = "toggle-focused",
  Toggle = "toggle",
  OpenRestoreMenu = "open-restore-menu",
  Open = "open",
  Hide = "hide",
  Restore = "restore",
  Close = "close",
  List = "list",
  Debug = "debug",
}

Constants.Command = {
  Restore = "restore",
  Close = "close",
  ToggleFocused = "toggle-focused",
  Toggle = "toggle",
}

Constants.Window = {
  HiddenWorkspace = "special:hidden",
  HiddenTitle = "Hidden window",
}

Constants.Storage = {
  RuntimeDirectory = "veil",
  StateFile = "hidden-windows.json",
  SelectionTargetFile = "selection-target.json",
}

return Constants
