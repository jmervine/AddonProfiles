#!/usr/bin/env lua
require("Libs.LUAUnit.WowStubs.WowStubs")

lu = require("Libs.LUAUnit.luaunit")

loadfile("Libs/LibStub/LibStub.lua")()
loadfile("Libs/AceConsole-3.0/AceConsole-3.0.lua")()
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
