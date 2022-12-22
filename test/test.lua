#!/usr/bin/env lua
require("Libs.WowStubs.WowStubs")

lu = require("Libs.LUAUnit.luaunit")

loadfile("Libs/Base64/base64.lua")()
loadfile("Libs/LibStub/LibStub.lua")()
loadfile("Libs/AceSerializer-3.0/AceSerializer-3.0.lua")()
loadfile("Libs/AceConsole-3.0/AceConsole-3.0.lua")()
--loadfile("Libs/AceGUI-3.0/AceGUI-3.0.lua")()
loadfile("Libs/AceAddon-3.0/AceAddon-3.0.lua")()

require("Core")

-- Right now, this requires that you manually add any new testing
-- files.
require("test.stub_test")
require("test.core_test")

-- EXEC
local runner = lu.LuaUnit.new()
runner:setOutputType("text")
os.exit(runner:runSuite())
