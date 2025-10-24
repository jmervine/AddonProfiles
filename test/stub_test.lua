-- Cringe, but I'm going to make sure my stubs work using a test suite of it's
-- own.

TestStubs = {} --class
  function TestStubs:test_wowstubs_UnitName()
    lu.assertEquals(UnitName("player"), "TestCharacter")
  end

  function TestStubs:test_wowstubs_AddonProfilesStore()
    -- Note: Tests may clear AddonProfilesStore, so we reinitialize if needed
    if not AddonProfilesStore then
      -- Reload the saved variables
      AddonProfilesStore = {
        ["Default"] = { "TestAddOn_One" },
        ["TestCharacter@Raiding"] = { "TestAddOn_One", "TestAddOn_Two" }
      }
    end
    lu.assertFalse(AddonProfilesStore == nil)
    lu.assertFalse(next(AddonProfilesStore) == nil)
  end

  function TestStubs:test_wowstubs_GetAddOnInfo()
    local aname, _, _, _, _, _, _ = GetAddOnInfo("TestAddon_One")
    lu.assertEquals(aname, "TestAddon_One")
  end

  function TestStubs:test_wowstubs_EnableAddOn()
    EnableAddOn("TestAddon_Two")
    lu.assertEquals(GetAddOnEnableState(nil, "TestAddon_Two"), 2)
  end

  function TestStubs:test_wowstubs_DisableAddOn()
    DisableAddOn("TestAddon_Two")
    lu.assertEquals(GetAddOnEnableState(nil, "TestAddon_Two"), 0)
  end

  function TestStubs:test_wowstubs_GetNumAddOns()
    lu.assertEquals(GetNumAddOns(), 3)
  end

