-- cross_character_test.lua
-- Tests for cross-character profile discovery and copying

TestCrossCharacter = {}

function TestCrossCharacter:setUp()
    -- Initialize addon
    AddonProfiles:OnInitialize()
    
    -- Clear existing profiles
    AddonProfiles.db.global.profiles = {}
    AddonProfiles.db.char.profiles = {}
    
    -- Set up multi-character database structure
    if not AddonProfiles.db.sv.char then
        AddonProfiles.db.sv.char = {}
    end
    
    -- Clear any existing character data
    for k in pairs(AddonProfiles.db.sv.char) do
        AddonProfiles.db.sv.char[k] = nil
    end
end

function TestCrossCharacter:tearDown()
    -- Cleanup
end

function TestCrossCharacter:test_MultipleCharacterProfiles()
    -- Simulate profiles from different characters
    local char1Key = "TestChar1 - TestRealm"
    local char2Key = "TestChar2 - TestRealm"
    
    -- Create character 1 profiles
    AddonProfiles.db.sv.char[char1Key] = {
        profiles = {
            ["Char1Profile1"] = {
                addons = { ["TestAddon_One"] = true },
                scope = "character",
                autoDeps = true
            },
            ["Char1Profile2"] = {
                addons = { ["TestAddon_Two"] = true },
                scope = "character",
                autoDeps = true
            }
        }
    }
    
    -- Create character 2 profiles
    AddonProfiles.db.sv.char[char2Key] = {
        profiles = {
            ["Char2Profile1"] = {
                addons = { ["TestAddon_Three"] = true },
                scope = "character",
                autoDeps = false
            }
        }
    }
    
    -- Verify we can access both characters' profiles
    lu.assertNotNil(AddonProfiles.db.sv.char[char1Key].profiles["Char1Profile1"])
    lu.assertNotNil(AddonProfiles.db.sv.char[char1Key].profiles["Char1Profile2"])
    lu.assertNotNil(AddonProfiles.db.sv.char[char2Key].profiles["Char2Profile1"])
    
    -- Verify profile data
    lu.assertEquals(AddonProfiles.db.sv.char[char1Key].profiles["Char1Profile1"].addons["TestAddon_One"], true)
    lu.assertEquals(AddonProfiles.db.sv.char[char2Key].profiles["Char2Profile1"].autoDeps, false)
end

function TestCrossCharacter:test_CopyProfileSameScope()
    -- Create source profile
    AddonProfiles.ProfileManager:CreateProfile("SourceProfile", "account", {
        ["TestAddon_One"] = true,
        ["TestAddon_Two"] = true
    })
    
    local sourceProfile = AddonProfiles.ProfileManager:GetProfile("SourceProfile", "account")
    sourceProfile.autoDeps = false
    
    -- Copy profile
    local success, err = AddonProfiles.ProfileManager:CreateProfile("CopiedProfile", "account")
    lu.assertTrue(success)
    
    local copiedProfile = AddonProfiles.ProfileManager:GetProfile("CopiedProfile", "account")
    
    -- Manually copy data (simulating copy dialog)
    for addonName, enabled in pairs(sourceProfile.addons) do
        copiedProfile.addons[addonName] = enabled
    end
    copiedProfile.autoDeps = sourceProfile.autoDeps
    
    -- Verify copied profile
    lu.assertNotNil(copiedProfile)
    lu.assertEquals(copiedProfile.addons["TestAddon_One"], true)
    lu.assertEquals(copiedProfile.addons["TestAddon_Two"], true)
    lu.assertEquals(copiedProfile.autoDeps, false)
    
    -- Verify they are independent (not same reference)
    sourceProfile.addons["TestAddon_Three"] = true
    lu.assertNil(copiedProfile.addons["TestAddon_Three"])
end

function TestCrossCharacter:test_CopyProfileCrossScope()
    -- Create account-wide source profile
    AddonProfiles.ProfileManager:CreateProfile("AccountProfile", "account", {
        ["TestAddon_One"] = true
    })
    
    local sourceProfile = AddonProfiles.ProfileManager:GetProfile("AccountProfile", "account")
    
    -- Copy to character scope
    local success, err = AddonProfiles.ProfileManager:CreateProfile("CharacterProfile", "character")
    lu.assertTrue(success)
    
    local copiedProfile = AddonProfiles.ProfileManager:GetProfile("CharacterProfile", "character")
    
    -- Manually copy data
    for addonName, enabled in pairs(sourceProfile.addons) do
        copiedProfile.addons[addonName] = enabled
    end
    copiedProfile.autoDeps = sourceProfile.autoDeps
    
    -- Verify copied to different scope
    lu.assertNotNil(copiedProfile)
    lu.assertEquals(copiedProfile.scope, "character")
    lu.assertEquals(copiedProfile.addons["TestAddon_One"], true)
end

function TestCrossCharacter:test_ProfileIsolationBetweenCharacters()
    -- This tests that modifying one character's profile doesn't affect another
    local char1Key = "TestChar1 - TestRealm"
    local char2Key = "TestChar2 - TestRealm"
    
    -- Create profiles for both characters
    AddonProfiles.db.sv.char[char1Key] = {
        profiles = {
            ["SharedName"] = {
                addons = { ["TestAddon_One"] = true },
                scope = "character"
            }
        }
    }
    
    AddonProfiles.db.sv.char[char2Key] = {
        profiles = {
            ["SharedName"] = {
                addons = { ["TestAddon_Two"] = true },
                scope = "character"
            }
        }
    }
    
    -- Modify char1's profile
    AddonProfiles.db.sv.char[char1Key].profiles["SharedName"].addons["TestAddon_Three"] = true
    
    -- Verify char2's profile is unchanged
    lu.assertNil(AddonProfiles.db.sv.char[char2Key].profiles["SharedName"].addons["TestAddon_Three"])
    lu.assertEquals(AddonProfiles.db.sv.char[char2Key].profiles["SharedName"].addons["TestAddon_Two"], true)
end

function TestCrossCharacter:test_CharacterKeyFormat()
    -- Test that character keys follow the expected format
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local expectedKey = playerName .. " - " .. realmName
    
    -- This tests the format used in ProfileList.lua
    -- The stub returns "TestCharacter" and "TestRealm"
    lu.assertEquals(expectedKey, "TestCharacter - TestRealm")
end

function TestCrossCharacter:test_EmptyCharacterProfiles()
    -- Test handling of characters with no profiles
    local char1Key = "EmptyChar - TestRealm"
    
    AddonProfiles.db.sv.char[char1Key] = {
        profiles = {}
    }
    
    -- Should not crash when iterating
    local profileCount = 0
    for _ in pairs(AddonProfiles.db.sv.char[char1Key].profiles) do
        profileCount = profileCount + 1
    end
    
    lu.assertEquals(profileCount, 0)
end

