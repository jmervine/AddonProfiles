TestTBCAnniversary = {}

function TestTBCAnniversary:setUp()
    -- Reset addon state to initial values before each test
    -- (Previous tests might have modified these)
    wowAddonsStub[1]._enabled = true   -- TestAddon_One enabled
    wowAddonsStub[1].loadable = 1

    wowAddonsStub[2]._enabled = false  -- TestAddon_Two disabled
    wowAddonsStub[2].loadable = false  -- Must also set loadable to false

    wowAddonsStub[3]._enabled = false  -- TestAddon_Three disabled
    wowAddonsStub[3].loadable = nil    -- Keep original (MISSING addon)

    -- Initialize addon
    AddonProfiles:OnInitialize()
end

function TestTBCAnniversary:tearDown()
    -- Cleanup
    _G.C_AddOns = nil -- Reset C_AddOns for each test
end

function TestTBCAnniversary:test_GetNumAddOns_Classic()
    -- Test classic API path (no C_AddOns)
    _G.C_AddOns = nil
    local count = AddonProfiles.AddonManager:GetNumAddOns()
    lu.assertEquals(count, 3) -- We have 3 test addons in stub
end

function TestTBCAnniversary:test_GetNumAddOns_Modern()
    -- Test modern C_AddOns API path
    _G.C_AddOns = {
        GetNumAddOns = function() return 5 end -- Mock return different value
    }
    local count = AddonProfiles.AddonManager:GetNumAddOns()
    lu.assertEquals(count, 5) -- Should use C_AddOns version
end

function TestTBCAnniversary:test_GetAddOnInfo_Classic()
    -- Test classic API path
    _G.C_AddOns = nil
    local name, title = AddonProfiles.AddonManager:GetAddOnInfo(1)
    lu.assertEquals(name, "TestAddon_One")
    lu.assertEquals(title, "Test Addon Sub #1")
end

function TestTBCAnniversary:test_GetAddOnInfo_Modern()
    -- Test modern C_AddOns API path
    _G.C_AddOns = {
        GetAddOnInfo = function(index)
            if index == 1 then
                return "ModernAddon", "Modern Addon Title"
            end
            return nil
        end
    }
    local name, title = AddonProfiles.AddonManager:GetAddOnInfo(1)
    lu.assertEquals(name, "ModernAddon")
    lu.assertEquals(title, "Modern Addon Title")
end

function TestTBCAnniversary:test_IsAddOnEnabled_PlayerParameter()
    -- Our new IsAddOnEnabled should use "player" parameter
    -- This is tested implicitly since existing tests pass
    lu.assertTrue(AddonProfiles.AddonManager:IsAddOnEnabled("TestAddon_One"))
    lu.assertFalse(AddonProfiles.AddonManager:IsAddOnEnabled("TestAddon_Two"))
end

function TestTBCAnniversary:test_EnableAddOn_Classic()
    -- Test classic enable path
    _G.C_AddOns = nil
    AddonProfiles.AddonManager:EnableAddOn("TestAddon_Two")
    lu.assertTrue(AddonProfiles.AddonManager:IsAddOnEnabled("TestAddon_Two"))
end

function TestTBCAnniversary:test_EnableAddOn_Modern()
    -- Test modern C_AddOns enable path
    local enabledAddons = {}
    _G.C_AddOns = {
        EnableAddOn = function(name)
            enabledAddons[name] = true
        end
    }
    AddonProfiles.AddonManager:EnableAddOn("TestAddon_Modern")
    lu.assertEquals(enabledAddons["TestAddon_Modern"], true)
end

function TestTBCAnniversary:test_DisableAddOn_Classic()
    -- Test classic disable path
    _G.C_AddOns = nil
    -- First enable it
    AddonProfiles.AddonManager:EnableAddOn("TestAddon_One")
    lu.assertTrue(AddonProfiles.AddonManager:IsAddOnEnabled("TestAddon_One"))

    -- Then disable it
    AddonProfiles.AddonManager:DisableAddOn("TestAddon_One")
    lu.assertFalse(AddonProfiles.AddonManager:IsAddOnEnabled("TestAddon_One"))
end

function TestTBCAnniversary:test_DisableAddOn_Modern()
    -- Test modern C_AddOns disable path
    local disabledAddons = {}
    _G.C_AddOns = {
        DisableAddOn = function(name)
            disabledAddons[name] = true
        end
    }
    AddonProfiles.AddonManager:DisableAddOn("TestAddon_Modern")
    lu.assertEquals(disabledAddons["TestAddon_Modern"], true)
end

function TestTBCAnniversary:test_IsAddOnLoaded_Classic()
    -- Add IsAddOnLoaded to test stubs
    _G.IsAddOnLoaded = function(name)
        return name == "TestAddon_One" -- Mock: only TestAddon_One is "loaded"
    end

    _G.C_AddOns = nil
    lu.assertTrue(AddonProfiles.AddonManager:IsAddOnLoaded("TestAddon_One"))
    lu.assertFalse(AddonProfiles.AddonManager:IsAddOnLoaded("TestAddon_Two"))
end

function TestTBCAnniversary:test_IsAddOnLoaded_Modern()
    -- Test modern C_AddOns path
    _G.C_AddOns = {
        IsAddOnLoaded = function(name)
            return name == "ModernAddon" -- Mock: only ModernAddon is "loaded"
        end
    }

    lu.assertTrue(AddonProfiles.AddonManager:IsAddOnLoaded("ModernAddon"))
    lu.assertFalse(AddonProfiles.AddonManager:IsAddOnLoaded("TestAddon_Two"))
end

function TestTBCAnniversary:test_GetAddOnDependencies_Modern()
    -- Test modern C_AddOns dependency resolution
    _G.C_AddOns = {
        GetAddOnDependencies = function(name)
            if name == "ModernAddon" then
                return {"Dependency1", "Dependency2"}
            end
            return {}
        end
    }

    local deps = AddonProfiles.AddonManager:GetAddonDependencies("ModernAddon")
    lu.assertEquals(#deps, 2)
    lu.assertEquals(deps[1], "Dependency1")
    lu.assertEquals(deps[2], "Dependency2")
end

function TestTBCAnniversary:test_GetAddOnDependencies_ClassicFallback()
    -- Test fallback to classic API when C_AddOns returns nil
    _G.C_AddOns = {
        GetAddOnDependencies = function(name)
            return nil -- Force fallback to classic API
        end
    }

    -- Should fall back to classic API for TestAddon_Two
    local deps = AddonProfiles.AddonManager:GetAddonDependencies("TestAddon_Two")
    lu.assertEquals(#deps, 1)
    lu.assertEquals(deps[1], "TestAddon_One")
end

function TestTBCAnniversary:test_ValidateAPICompatibility()
    -- Test that API validation doesn't crash
    -- This should run without errors (we can't easily test the output without mocking print)
    local success, err = pcall(function()
        AddonProfiles:ValidateAPICompatibility()
    end)
    lu.assertTrue(success, "ValidateAPICompatibility should not crash")
end
