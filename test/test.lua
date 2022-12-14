require('test.stubs.wow.globals')
lu = require('libs.luaunit')

-- Right now, this requires that you manually add any new testing
-- files.
require('test.stub_test')
require('test.core_test')

-- EXEC
local runner = lu.LuaUnit.new()
runner:setOutputType("text")
os.exit(runner:runSuite())
