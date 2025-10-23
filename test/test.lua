#!/usr/bin/env lua
require("Libs.LUAUnit.WowStubs.WowStubs")

lu = require("Libs.LUAUnit.luaunit")

loadfile("Libs/LibStub/LibStub.lua")()
loadfile("Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua")()
loadfile("Libs/AceConsole-3.0/AceConsole-3.0.lua")()
loadfile("Libs/AceAddon-3.0/AceAddon-3.0.lua")()
loadfile("Libs/AceDB-3.0/AceDB-3.0.lua")()

-- Load addon modules (Core must be first to create the addon)
require("Core")
require("AddonManager")
require("ProfileManager")

-- Load test files
require("test.stub_test")
require("test.addon_manager_test")
require("test.profile_manager_test")
require("test.migration_test")
require("test.core_test")

-- EXEC
local runner = lu.LuaUnit.new()
runner:setOutputType("text")
os.exit(runner:runSuite())
