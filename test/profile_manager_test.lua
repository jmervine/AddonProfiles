TestProfileManager = {}

function TestProfileManager:setUp()
    -- Initialize addon
    AddonProfiles:OnInitialize()
    
    -- Clear any existing profiles
    AddonProfiles.db.global.profiles = {}
    AddonProfiles.db.char.profiles = {}
    AddonProfiles.db.global.activeProfile = nil
    AddonProfiles.db.char.activeProfile = nil
end

function TestProfileManager:tearDown()
    -- Cleanup
end

function TestProfileManager:test_CreateProfile()
    -- Create character profile
    local success, err = AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {})
    lu.assertTrue(success)
    lu.assertNil(err)
    
    -- Verify profile exists
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertNotNil(profile)
    lu.assertEquals(profile.scope, "character")
    lu.assertTrue(profile.autoDeps)
end

function TestProfileManager:test_CreateProfile_Duplicate()
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {})
    
    -- Try to create duplicate
    local success, err = AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {})
    lu.assertFalse(success)
    lu.assertNotNil(err)
end

function TestProfileManager:test_DeleteProfile()
    -- Create and delete profile
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "account", {})
    
    local success = AddonProfiles.ProfileManager:DeleteProfile("TestProfile", "account")
    lu.assertTrue(success)
    
    -- Verify deleted
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "account")
    lu.assertNil(profile)
end

function TestProfileManager:test_GetAllProfiles()
    -- Create profiles in both scopes
    AddonProfiles.ProfileManager:CreateProfile("CharProfile", "character", {})
    AddonProfiles.ProfileManager:CreateProfile("AcctProfile", "account", {})
    
    -- Get all
    local all = AddonProfiles.ProfileManager:GetAllProfiles("all")
    lu.assertNotNil(all["CharProfile"])
    lu.assertNotNil(all["AcctProfile"])
    
    -- Get character only
    local charOnly = AddonProfiles.ProfileManager:GetAllProfiles("character")
    lu.assertNotNil(charOnly["CharProfile"])
    lu.assertNil(charOnly["AcctProfile"])
    
    -- Get account only
    local acctOnly = AddonProfiles.ProfileManager:GetAllProfiles("account")
    lu.assertNil(acctOnly["CharProfile"])
    lu.assertNotNil(acctOnly["AcctProfile"])
end

function TestProfileManager:test_UpdateProfile()
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", { ["TestAddon_One"] = true })
    
    -- Update addons
    local success = AddonProfiles.ProfileManager:UpdateProfile("TestProfile", "character", {
        addons = { ["TestAddon_Two"] = true },
        autoDeps = false
    })
    lu.assertTrue(success)
    
    -- Verify update
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertEquals(profile.addons["TestAddon_Two"], true)
    lu.assertNil(profile.addons["TestAddon_One"])
    lu.assertFalse(profile.autoDeps)
end

function TestProfileManager:test_RenameProfile()
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("OldName", "character", {})
    
    -- Rename
    local success = AddonProfiles.ProfileManager:RenameProfile("OldName", "NewName", "character")
    lu.assertTrue(success)
    
    -- Verify rename
    lu.assertNil(AddonProfiles.ProfileManager:GetProfile("OldName", "character"))
    lu.assertNotNil(AddonProfiles.ProfileManager:GetProfile("NewName", "character"))
end

function TestProfileManager:test_GetProfileAddonCount()
    -- Create profile with addons
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {
        ["TestAddon_One"] = true,
        ["TestAddon_Two"] = true
    })
    
    -- Count without dependencies
    local count = AddonProfiles.ProfileManager:GetProfileAddonCount("TestProfile", "character", false)
    lu.assertEquals(count, 2)
    
    -- Count with dependencies (TestAddon_Two depends on TestAddon_One, so no extra deps)
    local countWithDeps = AddonProfiles.ProfileManager:GetProfileAddonCount("TestProfile", "character", true)
    lu.assertEquals(countWithDeps, 2) -- Still 2 because both are already in the list
end

function TestProfileManager:test_SaveCurrentState()
    -- Enable some addons
    EnableAddOn("TestAddon_One")
    EnableAddOn("TestAddon_Two")
    
    -- Create profile
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {})
    
    -- Save current state
    local success = AddonProfiles.ProfileManager:SaveCurrentState("TestProfile", "character")
    lu.assertTrue(success)
    
    -- Verify saved
    local profile = AddonProfiles.ProfileManager:GetProfile("TestProfile", "character")
    lu.assertEquals(profile.addons["TestAddon_One"], true)
    lu.assertEquals(profile.addons["TestAddon_Two"], true)
end

function TestProfileManager:test_ActiveProfile()
    -- Create and activate profile
    AddonProfiles.ProfileManager:CreateProfile("TestProfile", "character", {
        ["TestAddon_One"] = true
    })
    
    local success = AddonProfiles.ProfileManager:ActivateProfile("TestProfile", "character")
    lu.assertTrue(success)
    
    -- Check active profile
    local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
    lu.assertEquals(activeName, "TestProfile")
    lu.assertEquals(activeScope, "character")
end

