#!/usr/bin/env lua
local core = require('core.core')

if os.getenv("DEBUG") == "true" then
  core.DEBUG = true
end

TestCore = {} --class
  function TestCore:setUp()
    -- setups
    core.SetAddOnState()
    core.LoadAddOnTemplates()
  end

  function TestStubs:test_SetAddOnState()
    local addon = "TestAddOn_One"

    lu.assertFalse(core.CurrentState[addon] == nil or core.CurrentState[addon] == {})
    lu.assertEquals(core.CurrentState[addon].Name, addon)
  end

  function TestCore:test_LoadAddOnTemplates_withAddOnTemplates()
    lu.assertFalse(core.Templates == nil)
    lu.assertFalse(AddOnTemplates == nil)
    --lu.assertEqual(core.Templates, AddOnTemplates)

    local default = core.Templates["Default"]
    lu.assertFalse(default == nil or default == {})

    local addon = default["TestAddOn_One"]
    lu.assertFalse(addon == {} or addon == nil)
    lu.assertEquals(addon.Name, "TestAddOn_One")
    lu.assertTrue(addon.Installed)
  end
