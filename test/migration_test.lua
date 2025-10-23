TestMigration = {}

function TestMigration:setUp()
    -- Clear any existing state
    AddonProfilesDB = nil
    AddonProfilesStore = nil
end

function TestMigration:tearDown()
    -- Cleanup
    AddonProfilesDB = nil
    AddonProfilesStore = nil
end

function TestMigration:test_MigrateOldData_EmptyStore()
    -- Test with no old data
    AddonProfilesStore = nil
    AddonProfiles:OnInitialize()
    
    -- Should create empty database
    lu.assertNotNil(AddonProfiles.db)
    lu.assertNotNil(AddonProfiles.db.global.profiles)
    lu.assertNotNil(AddonProfiles.db.char.profiles)
end

function TestMigration:test_MigrateOldData_WithProfiles()
    -- Set up old format data
    AddonProfilesStore = {
        ["TestCharacter@Default"] = { "TestAddon_One", "TestAddon_Two" },
        ["Raiding"] = { "TestAddon_One" }
    }
    
    -- Initialize (should trigger migration)
    AddonProfiles:OnInitialize()
    
    -- Verify migration to character scope
    local defaultProfile = AddonProfiles.ProfileManager:GetProfile("TestCharacter@Default", "character")
    lu.assertNotNil(defaultProfile)
    lu.assertEquals(defaultProfile.scope, "character")
    lu.assertTrue(defaultProfile.autoDeps)
    lu.assertEquals(defaultProfile.addons["TestAddon_One"], true)
    lu.assertEquals(defaultProfile.addons["TestAddon_Two"], true)
    
    local raidingProfile = AddonProfiles.ProfileManager:GetProfile("Raiding", "character")
    lu.assertNotNil(raidingProfile)
    lu.assertEquals(raidingProfile.addons["TestAddon_One"], true)
end

function TestMigration:test_MigrateOldData_ArrayToMapConversion()
    -- Set up old format data (array style)
    AddonProfilesStore = {
        ["TestProfile"] = { "TestAddon_One", "TestAddon_Two", "TestAddon_Three" }
    }
    
    -- Initialize
    AddonProfiles:OnInitialize()
    
    -- Verify conversion to map format
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertNotNil(profile)
    
    -- Should be a map, not an array
    lu.assertEquals(profile.addons["TestAddon_One"], true)
    lu.assertEquals(profile.addons["TestAddon_Two"], true)
    lu.assertEquals(profile.addons["TestAddon_Three"], true)
    
    -- Array indices should not exist
    lu.assertNil(profile.addons[1])
    lu.assertNil(profile.addons[2])
    lu.assertNil(profile.addons[3])
end

function TestMigration:test_NoDoubleMigration()
    -- Set up old format data
    AddonProfilesStore = {
        ["TestProfile"] = { "TestAddon_One" }
    }
    
    -- First initialization (migration happens)
    AddonProfiles:OnInitialize()
    
    -- Modify the migrated profile
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    profile.addons["TestAddon_Two"] = true
    
    -- Second initialization (should not re-migrate)
    AddonProfiles:MigrateOldData()
    
    -- Verify modifications are preserved (not overwritten by migration)
    profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertEquals(profile.addons["TestAddon_One"], true)
    lu.assertEquals(profile.addons["TestAddon_Two"], true) -- Should still be there
end

