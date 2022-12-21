TestCore = {} --class

  -- setup / teardown
  function TestCore:setUp()
    -- setups
    AddonProfiles:OnInitialize()

    TestCore.backupStore = AddonProfilesStore
  end

  function TestCore:tearDown()
    AddonProfilesStore = TestCore.backupStore
  end

  -- TESTS
  function TestCore:test_OnInitialize_onEmpty()
    AddonProfilesStore = nil
    AddonProfiles:OnInitialize()

    local pname = "TestCharacter@Default"
    lu.assertFalse(not AddonProfilesStore)
    lu.assertFalse(next(AddonProfilesStore) == false)
    lu.assertFalse(not AddonProfilesStore[pname])
    lu.assertFalse(next(AddonProfilesStore[pname]) == nil)
  end

  function TestCore:test_OnInitialize_withData()
    local pname = "New_Profile"
    AddonProfilesStore = {
      [pname] = { "TestAddon_One", "TestAddon_Two" }
    }
    -- AddonProfiles:OnInitialize() is run before every test, so we don't need
    -- to run it here.
    lu.assertFalse(not AddonProfilesStore)
    lu.assertFalse(next(AddonProfilesStore) == false)
    lu.assertFalse(not AddonProfilesStore[pname])
    lu.assertFalse(next(AddonProfilesStore[pname]) == nil)
  end

  function TestCore:test_getAddons()
    local addons = AddonProfiles:getAddons()
    lu.assertEquals(addons, { "TestAddon_One", "TestAddon_Two" })
  end

  function TestCore:test_saveAddonProfile()
    local state1 = { "TestAddon_One", "TestAddon_Two" }

    AddonProfilesStore = nil
    AddonProfiles:saveAddonProfile("Test_Profile1", state1)

    lu.assertEquals(AddonProfilesStore["Test_Profile1"], state1)

    local state2 = state1
    table.insert(state2, "TestAddon_Three")
    AddonProfiles:saveAddonProfile("Test_Profile2", state2)

    lu.assertEquals(AddonProfilesStore["Test_Profile1"], state1)
    lu.assertEquals(AddonProfilesStore["Test_Profile2"], state2)
  end

  function TestCore:test_deleteProfile()
    local state = { "TestAddon_One", "TestAddon_Two" }
    AddonProfilesStore["Test_Delete"] = state

    local removed = AddonProfiles:deleteProfile("Test_Delete")
    lu.assertTrue(removed)
    lu.assertTrue(AddonProfilesStore["Test_Delete"] == nil)

    removed = AddonProfiles:deleteProfile("Test_Delete")
    lu.assertFalse(removed)
  end
