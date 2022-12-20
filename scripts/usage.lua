#!/usr/bin/env lua
require("Libs.LUAUnit.WowStubs.WowStubs")

loadfile("Libs/LibStub/LibStub.lua")()
loadfile("Libs/AceConsole-3.0/AceConsole-3.0.lua")()
loadfile("Libs/AceAddon-3.0/AceAddon-3.0.lua")()
require("Core")

function AddOnTemplates:Print(str)
  print(string.format("[%s] %s", ADDON_NAME, str))
end

AddOnTemplates:Help()
