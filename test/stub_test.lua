-- Cringe, but I'm going to make sure my stubs work using a test suite of it's
-- own.

TestStubs = {} --class
  function TestStubs:test_wowstubs_UnitName()
    lu.assertEquals(UnitName("player"), "TestCharacter")
  end

  function TestStubs:test_wowstubs_AddOnTemplates()
    lu.assertFalse(AddOnTemplates == nil)
    lu.assertFalse(next(AddOnTemplates) == nil)
  end

  function TestStubs:test_wowstubs_GetAddOnInfo()
    local aname, _, _, _, _, _, _ = GetAddOnInfo("TestAddOn_One")
    lu.assertEquals(aname, "TestAddOn_One")
  end

  function TestStubs:test_wowstubs_EnableAddOn()
    EnableAddOn("TestAddOn_Two")
    lu.assertEquals(GetAddOnEnableState(nil, "TestAddOn_Two"), 2)
  end

  function TestStubs:test_wowstubs_DisableAddOn()
    DisableAddOn("TestAddOn_Two")
    lu.assertEquals(GetAddOnEnableState(nil, "TestAddOn_One"), 0)
  end

  function TestStubs:test_wowstubs_GetNumAddOns()
    lu.assertEquals(GetNumAddOns(), 2)
  end

