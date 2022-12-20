TestCore = {} --class

  -- setup / teardown
  function TestCore:setUp()
    -- setups
    AddOnTemplates:OnInitialize()

    TestCore.backupStore = AddOnTemplatesStore
  end

  function TestCore:tearDown()
    AddOnTemplatesStore = TestCore.backupStore
  end

  -- TESTS
  function TestCore:test_OnInitialize()
    -- AddOnTemplates:OnInitialize() is run before every test, so we don't need
    -- to run it here.
    lu.assertFalse(not AddOnTemplatesStore)
    lu.assertFalse(next(AddOnTemplatesStore) == false)
    lu.assertFalse(not AddOnTemplatesStore["default"])
    lu.assertFalse(next(AddOnTemplatesStore["default"]) == nil)
  end

  function TestCore:test_getAddOns()
    local addons = AddOnTemplates:getAddOns()
    lu.assertEquals(addons, { "TestAddOn_One" })
  end

  function TestCore:test_saveAddOnTemplate()
    local state1 = { "TestAddOn_One", "TestAddOn_Two" }

    AddOnTemplatesStore = nil
    AddOnTemplates:saveAddOnTemplate("Test_Template1", state1)

    lu.assertEquals(AddOnTemplatesStore["Test_Template1"], state1)

    local state2 = state1
    table.insert(state2, "TestAddOn_Three")
    AddOnTemplates:saveAddOnTemplate("Test_Template2", state2)

    lu.assertEquals(AddOnTemplatesStore["Test_Template1"], state1)
    lu.assertEquals(AddOnTemplatesStore["Test_Template2"], state2)
  end

  function TestCore:test_deleteTemplate()
    local state = { "TestAddOn_One", "TestAddOn_Two" }
    AddOnTemplatesStore["Test_Delete"] = state

    local removed = AddOnTemplates:deleteTemplate("Test_Delete")
    lu.assertTrue(removed)
    lu.assertTrue(AddOnTemplatesStore["Test_Delete"] == nil)

    removed = AddOnTemplates:deleteTemplate("Test_Delete")
    lu.assertFalse(removed)
  end
