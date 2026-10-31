--!nonstrict

local Constants = {}

Constants.Plugin = {
  Id = "whereareiam/ryujin-screen",
  ControlPanelId = "whereareiam/ryujin-screen:control",
}

Constants.State = {
  Status = "status",
  Media = "media",
  Command = "command",
  PanelOpen = "panel-open",
}

Constants.Command = {
  Show = "show",
  Brightness = "brightness",
  Power = "power",
  StartService = "start-service",
  Refresh = "refresh",
}

Constants.Event = {
  Open = "open",
  On = "on",
  Off = "off",
  Toggle = "toggle",
  Dashboard = "dashboard",
  BuiltIn = "built-in",
  Brightness = "brightness",
  Refresh = "refresh",
}

Constants.Mode = {
  Dashboard = "dashboard",
  BuiltIn = "built-in",
  Image = "image",
  Gif = "gif",
}

Constants.Media = {
  ImageExtensions = { png = true, jpg = true, jpeg = true, webp = true, bmp = true },
  GifExtension = "gif",
  DefaultFolder = "~/Pictures/Ryujin",
}

Constants.Poll = {
  PanelOpenMs = 3000,
  PanelClosedMs = 30000,
}

Constants.Service = {
  Executable = "ryujin-screen",
  LocalExecutable = "~/.local/bin/ryujin-screen",
  Unit = "ryujin-screen.service",
}

return Constants
