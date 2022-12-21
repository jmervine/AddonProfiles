#!/usr/bin/env lua
require("Libs.LUAUnit.WowStubs.WowStubs")

loadfile("Libs/LibStub/LibStub.lua")()
loadfile("Libs/AceConsole-3.0/AceConsole-3.0.lua")()
loadfile("Libs/AceAddon-3.0/AceAddon-3.0.lua")()
require("Core")

local this = AddonProfiles
print(string.format("Usage: /%s [option] (aliases: '%s')", this.SlashCommands, table.concat(this.SlashAliases, "', '")))

for cmd, cfg in pairs(this.HelpMessages) do
  print(string.format("  '%s %s': %s", cmd, cfg.opts, cfg.desc))
end
