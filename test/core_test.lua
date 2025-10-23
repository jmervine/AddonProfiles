TestCore = {}

-- setup / teardown
function TestCore:setUp()
    -- Clear any existing state
    AddonProfilesDB = nil
    AddonProfilesStore = nil
    
    -- Initialize addon
    AddonProfiles:OnInitialize()
end

function TestCore:tearDown()
    AddonProfilesDB = nil
    AddonProfilesStore = nil
end

-- TESTS
function TestCore:test_OnInitialize_CreatesDatabase()
    lu.assertNotNil(AddonProfiles.db)
    lu.assertNotNil(AddonProfiles.db.global)
    lu.assertNotNil(AddonProfiles.db.char)
    lu.assertNotNil(AddonProfiles.db.global.profiles)
    lu.assertNotNil(AddonProfiles.db.char.profiles)
end

function TestCore:test_OnInitialize_WithOldData()
    -- Setup old data
    AddonProfilesStore = {
        ["TestProfile"] = { "TestAddon_One", "TestAddon_Two" }
    }
    
    -- Re-initialize
    AddonProfiles:OnInitialize()
    
    -- Verify migration
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertNotNil(profile)
    lu.assertEquals(profile.addons["TestAddon_One"], true)
    lu.assertEquals(profile.addons["TestAddon_Two"], true)
end

function TestCore:test_ModulesLoaded()
    -- Verify all modules are accessible
    lu.assertNotNil(AddonProfiles.AddonManager)
    lu.assertNotNil(AddonProfiles.ProfileManager)
end

function TestCore:test_NewProfile_Command()
    -- Execute slash command to create profile
    AddonProfiles:NewProfile("TestNewProfile", "character")
    
    -- Verify created
    local profile = AddonProfiles.ProfileManager:GetProfile("TestNewProfile", "character")
    lu.assertNotNil(profile)
    lu.assertEquals(profile.scope, "character")
end

function TestCore:test_DeleteProfile_Command()
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("TestDeleteProfile", "character", {})
    
    -- Delete via command
    AddonProfiles:DeleteProfile("TestDeleteProfile")
    
    -- Verify deleted
    local profile = AddonProfiles.ProfileManager:GetProfile("TestDeleteProfile", "character")
    lu.assertNil(profile)
end

function TestCore:test_SaveProfile_Command()
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("TestSaveProfile", "character", {})
    
    -- Enable some addons
    EnableAddOn("TestAddon_One")
    EnableAddOn("TestAddon_Two")
    
    -- Save via command
    AddonProfiles:SaveProfile("TestSaveProfile")
    
    -- Verify saved
    local profile = AddonProfiles.ProfileManager:GetProfile("TestSaveProfile", "character")
    lu.assertEquals(profile.addons["TestAddon_One"], true)
    lu.assertEquals(profile.addons["TestAddon_Two"], true)
end

function TestCore:test_LoadProfile_Command()
    -- Create profile with specific addons
    AddonProfiles.ProfileManager:CreateProfile("TestLoadProfile", "character", {
        ["TestAddon_Two"] = true
    })
    
    -- Load via command (uses ReloadUI stub)
    AddonProfiles:LoadProfile("TestLoadProfile")
    
    -- Verify active profile set
    local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
    lu.assertEquals(activeName, "TestLoadProfile")
    lu.assertEquals(activeScope, "character")
end
