TestCore = {} --class
  TestCore.addOnTemplatesBackup = nil
  TestCore.currentStateBackup = nil

  local function zeroAddOnTemplates()
    AddOnTemplates = nil
    Core.Templates = nil
  end

  function TestCore:setUp()
    -- setups
    Core.Initialize()

    TestCore.addOnTemplatesBackup = AddOnTemplates
    TestCore.currentStateBackup   = Core.CurrentState
  end

  function TestCore:tearDown()
    AddOnTemplates    = TestCore.addOnTemplatesBackup
    Core.CurrentState = TestCore.currentStateBackup
  end

  function TestStubs:test_SetAddOnState()
    local addon = "TestAddOn_One"

    lu.assertFalse(Core.CurrentState[addon] == nil)
    lu.assertFalse(next(Core.CurrentState[addon]) == nil)
    lu.assertEquals(Core.CurrentState[addon].Name, addon)
  end

  function TestCore:test_loadTemplates_withPreviouslySaved()
    -- Depends on the call to the public "core:LoadAddOnTemplates()" function
    -- within the "core:Inititalize()" function, however, we're only testing
    -- logic within 'local function loadTemplates'.
    local name = Core.Templates["Default"]["TestAddOn_One"].Name
    lu.assertEquals(name, "TestAddOn_One")
  end

  function TestCore:test_loadTemplates_withoutPreviouslySaved()
    -- Calling the public function, however, we're only testing the logic
    -- within 'local function loadTemplates'.
    --
    -- Store AddOnTempaltes for later reset.
    zeroAddOnTemplates()

    Core.LoadAddOnTemplates()

    -- actual tests
    local name = Core.Templates["Default"]["TestAddOn_One"].Name
    lu.assertEquals(name, "TestAddOn_One")
  end

  function TestCore:test_filteredUninstalledAddOns()
    -- Calling the public function, however, we're only testing the logic
    -- within 'local function loadTemplates'.

    -- Set installed to false for testing. Will be reset by tearDown.
    Core.CurrentState = {
      ["TestAddOn_One"] = TestCore.currentStateBackup["TestAddOn_One"]
    }

    Core.LoadAddOnTemplates()

    lu.assertFalse(Core.Templates["TestCharacter@Raiding"]["TestAddOn_Two"].Installed)
  end

  function TestCore:test_LoadAddOnTemplates()
    lu.assertEquals(Core.CurrentStateEnablement, 2) -- TODO: Need more tests around this.

    local default = Core.Templates["Default"]
    lu.assertFalse(default == nil)
    lu.assertFalse(next(default) == nil)
  end

  function TestCore:test_LoadAddOnsTemplate()
    Core.LoadAddOnsTemplate("Default")

    lu.assertFalse(Core.CurrentState["TestAddOn_One"] == nil)

    local found = false
    for _, v in ipairs(wowAddOnsEnabled) do
      found = (name == "TestAddOn_Two")
      if found then break end
    end
    lu.assertFalse(found)
  end

  function TestCore:test_SaveAddOnsTemplate()
    Core.SaveAddOnsTemplate("TestNew")

    lu.assertFalse(not Core.Templates["TestNew"])
    lu.assertFalse(not AddOnTemplates["TestNew"])
  end
