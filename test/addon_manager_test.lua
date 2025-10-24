TestAddonManager = {}

function TestAddonManager:setUp()
    -- Initialize addon
    AddonProfiles:OnInitialize()
end

function TestAddonManager:tearDown()
    -- Cleanup
end

function TestAddonManager:test_GetAllAddons()
    local addons = AddonProfiles.AddonManager:GetAllAddons()
    
    lu.assertNotNil(addons)
    lu.assertNotNil(addons["TestAddon_One"])
    lu.assertNotNil(addons["TestAddon_Two"])
    lu.assertNotNil(addons["TestAddon_Three"])
    
    -- Check structure
    local addon1 = addons["TestAddon_One"]
    lu.assertEquals(addon1.name, "TestAddon_One")
    lu.assertEquals(addon1.title, "Test Addon Sub #1")
    lu.assertTrue(addon1.enabled) -- TestAddon_One is enabled in stub
end

function TestAddonManager:test_GetAddonDependencies()
    -- TestAddon_One has no dependencies
    local deps1 = AddonProfiles.AddonManager:GetAddonDependencies("TestAddon_One")
    lu.assertEquals(#deps1, 0)
    
    -- TestAddon_Two depends on TestAddon_One
    local deps2 = AddonProfiles.AddonManager:GetAddonDependencies("TestAddon_Two")
    lu.assertEquals(#deps2, 1)
    lu.assertEquals(deps2[1], "TestAddon_One")
end

function TestAddonManager:test_IsAddonEnabled()
    lu.assertTrue(AddonProfiles.AddonManager:IsAddonEnabled("TestAddon_One"))
    lu.assertFalse(AddonProfiles.AddonManager:IsAddonEnabled("TestAddon_Two"))
end

function TestAddonManager:test_EnableDisableAddons()
    -- Enable addon
    AddonProfiles.AddonManager:EnableAddons({ "TestAddon_Two" })
    lu.assertTrue(AddonProfiles.AddonManager:IsAddonEnabled("TestAddon_Two"))
    
    -- Disable addon
    AddonProfiles.AddonManager:DisableAddons({ "TestAddon_Two" })
    lu.assertFalse(AddonProfiles.AddonManager:IsAddonEnabled("TestAddon_Two"))
end

function TestAddonManager:test_ResolveDependencies()
    -- Without autoDeps
    local addons = { ["TestAddon_Two"] = true }
    local resolved = AddonProfiles.AddonManager:ResolveDependencies(addons, false)
    lu.assertEquals(resolved["TestAddon_Two"], true)
    lu.assertNil(resolved["TestAddon_One"]) -- Dependency not included
    
    -- With autoDeps
    resolved = AddonProfiles.AddonManager:ResolveDependencies(addons, true)
    lu.assertEquals(resolved["TestAddon_Two"], true)
    lu.assertEquals(resolved["TestAddon_One"], true) -- Dependency included
end

function TestAddonManager:test_GetDependencyCount()
    local addons = { ["TestAddon_Two"] = true }
    
    -- Without autoDeps
    local count = AddonProfiles.AddonManager:GetDependencyCount(addons, false)
    lu.assertEquals(count, 0)
    
    -- With autoDeps
    count = AddonProfiles.AddonManager:GetDependencyCount(addons, true)
    lu.assertEquals(count, 1) -- TestAddon_One is a dependency
end

