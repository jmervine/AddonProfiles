#!/usr/bin/env lua
require('test.stubs.wow.globals')
lu = require('libs.luaunit')

require('libs.helpers')
require('core.core')
require('cmds.cmds')

Helpers.DEBUG = (os.getenv("DEBUG") == "true")

-- Right now, this requires that you manually add any new testing
-- files.
require('test.stub_test')
require('test.core_test')
require('test.cmds_test')

-- EXEC
local runner = lu.LuaUnit.new()
runner:setOutputType("text")
os.exit(runner:runSuite())
