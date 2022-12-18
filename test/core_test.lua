#!/usr/bin/env lua
local core = require('core.core')

TestCore = {} --class
  TestCore.addOnTemplatesBackup = nil
  TestCore.currentStateBackup = nil

  local function zeroAddOnTemplates()
    AddOnTemplates = nil
    core.Templates = nil
  end

  function TestCore:setUp()
    -- setups
    core:Initialize()

    TestCore.addOnTemplatesBackup = AddOnTemplates
    TestCore.currentStateBackup   = core.CurrentState
  end

  function TestCore:tearDown()
    AddOnTemplates    = TestCore.addOnTemplatesBackup
    core.CurrentState = TestCore.currentStateBackup
  end

  function TestStubs:test_SetAddOnState()
    local addon = "TestAddOn_One"

    lu.assertFalse(core.CurrentState[addon] == nil)
    lu.assertFalse(next(core.CurrentState[addon]) == nil)
    lu.assertEquals(core.CurrentState[addon].Name, addon)
  end

  function TestCore:test_loadTemplates_withPreviouslySaved()
    -- Depends on the call to the public "core:LoadAddOnTemplates()" function
    -- within the "core:Inititalize()" function, however, we're only testing
    -- logic within 'local function loadTemplates'.
    local name = core.Templates["Default"]["TestAddOn_One"].Name
    lu.assertEquals(name, "TestAddOn_One")
  end

  function TestCore:test_loadTemplates_withoutPreviouslySaved()
    -- Calling the public function, however, we're only testing the logic
    -- within 'local function loadTemplates'.
    --
    -- Store AddOnTempaltes for later reset.
    zeroAddOnTemplates()

    core.LoadAddOnTemplates()

    -- actual tests
    local name = core.Templates["Default"]["TestAddOn_One"].Name
    lu.assertEquals(name, "TestAddOn_One")
  end

  function TestCore:test_filteredUninstalledAddOns()
    -- Calling the public function, however, we're only testing the logic
    -- within 'local function loadTemplates'.

    -- Set installed to false for testing. Will be reset by tearDown.
    core.CurrentState = {
      ["TestAddOn_One"] = TestCore.currentStateBackup["TestAddOn_One"]
    }

    core.LoadAddOnTemplates()

    lu.assertFalse(core.Templates["TestCharacter@Raiding"]["TestAddOn_Two"].Installed)
  end

  function TestCore:test_LoadAddOnTemplates()
    lu.assertEquals(core.CurrentStateEnablement, 2) -- TODO: Need more tests around this.

    local default = core.Templates["Default"]
    lu.assertFalse(default == nil)
    lu.assertFalse(next(default) == nil)
  end

  function TestCore:test_LoadAddOnsTemplate()
    core:LoadAddOnsTemplate("Default")

    lu.assertFalse(core.CurrentState["TestAddOn_One"] == nil)

    local found = false
    for _, v in ipairs(wowAddOnsEnabled) do
      found = (name == "TestAddOn_Two")
      if found then break end
    end
    lu.assertFalse(found)
  end
