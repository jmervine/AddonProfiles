-- AddonManager.lua
-- Handles addon discovery, dependency tracking, and enable/disable operations

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AddonManager = {}
AddonProfiles.AddonManager = AddonManager

-- GetAllAddons returns a table of all installed addons
-- Returns: { [addonName] = { name, title, enabled, loadable, reason, security, dependencies } }
function AddonManager:GetAllAddons()
    local addons = {}
    local numAddons = GetNumAddOns()
    
    for i = 1, numAddons do
        local name, title, _, loadable, reason, security = GetAddOnInfo(i)
        local enabled = GetAddOnEnableState(nil, name) > 0
        local dependencies = self:GetAddonDependencies(name)
        
        addons[name] = {
            name = name,
            title = title or name,
            enabled = enabled,
            loadable = loadable,
            reason = reason,
            security = security,
            dependencies = dependencies,
            index = i
        }
    end
    
    return addons
end

-- GetAddonDependencies returns a list of dependency names for the given addon
-- Parameters:
--   addonName: string - name of the addon
-- Returns: table - array of dependency addon names
function AddonManager:GetAddonDependencies(addonName)
    local dependencies = {}
    local numAddons = GetNumAddOns()
    
    -- Find addon index
    local addonIndex = nil
    for i = 1, numAddons do
        local name = GetAddOnInfo(i)
        if name == addonName then
            addonIndex = i
            break
        end
    end
    
    if not addonIndex then
        return dependencies
    end
    
    -- Get dependencies
    -- GetAddOnDependencies returns all deps as multiple return values
    local numDeps = select("#", GetAddOnDependencies(addonIndex))
    if numDeps and numDeps > 0 then
        for i = 1, numDeps do
            local depName = select(i, GetAddOnDependencies(addonIndex))
            if depName and depName ~= "" then
                table.insert(dependencies, depName)
            end
        end
    end
    
    return dependencies
end

-- IsAddonEnabled checks if an addon is currently enabled
-- Parameters:
--   addonName: string - name of the addon
-- Returns: boolean
function AddonManager:IsAddonEnabled(addonName)
    return GetAddOnEnableState(nil, addonName) > 0
end

-- EnableAddons enables the specified list of addons
-- Parameters:
--   addonList: table - array of addon names or { [addonName] = true } map
function AddonManager:EnableAddons(addonList)
    if not addonList then return end
    
    -- Handle both array and map formats
    for key, value in pairs(addonList) do
        local addonName
        if type(key) == "number" then
            -- Array format: { "Addon1", "Addon2" }
            addonName = value
        else
            -- Map format: { ["Addon1"] = true, ["Addon2"] = true }
            if value then
                addonName = key
            end
        end
        
        if addonName then
            EnableAddOn(addonName)
        end
    end
end

-- DisableAddons disables the specified list of addons
-- Parameters:
--   addonList: table - array of addon names or { [addonName] = true } map
function AddonManager:DisableAddons(addonList)
    if not addonList then return end
    
    -- Handle both array and map formats
    for key, value in pairs(addonList) do
        local addonName
        if type(key) == "number" then
            -- Array format: { "Addon1", "Addon2" }
            addonName = value
        else
            -- Map format: { ["Addon1"] = true, ["Addon2"] = true }
            if value then
                addonName = key
            end
        end
        
        if addonName then
            DisableAddOn(addonName)
        end
    end
end

-- ResolveDependencies expands an addon list with its dependencies
-- Parameters:
--   addonList: table - { [addonName] = true } map
--   autoDeps: boolean - whether to automatically include dependencies
-- Returns: table - { [addonName] = true } map with dependencies added
function AddonManager:ResolveDependencies(addonList, autoDeps)
    if not autoDeps or not addonList then
        return addonList
    end
    
    local resolved = {}
    local toProcess = {}
    
    -- Initialize with original list
    for addonName, enabled in pairs(addonList) do
        if enabled then
            resolved[addonName] = true
            table.insert(toProcess, addonName)
        end
    end
    
    -- Process dependencies recursively
    while #toProcess > 0 do
        local current = table.remove(toProcess, 1)
        local deps = self:GetAddonDependencies(current)
        
        for _, depName in ipairs(deps) do
            if not resolved[depName] then
                resolved[depName] = true
                table.insert(toProcess, depName)
            end
        end
    end
    
    return resolved
end

-- GetDependencyCount counts how many additional addons would be enabled by dependencies
-- Parameters:
--   addonList: table - { [addonName] = true } map
--   autoDeps: boolean - whether auto-deps is enabled
-- Returns: number - count of additional dependencies
function AddonManager:GetDependencyCount(addonList, autoDeps)
    if not autoDeps or not addonList then
        return 0
    end
    
    local resolved = self:ResolveDependencies(addonList, autoDeps)
    local originalCount = 0
    local resolvedCount = 0
    
    for _ in pairs(addonList) do
        originalCount = originalCount + 1
    end
    
    for _ in pairs(resolved) do
        resolvedCount = resolvedCount + 1
    end
    
    return resolvedCount - originalCount
end

-- GetAddonInfo returns detailed info about a specific addon
-- Parameters:
--   addonName: string - name of the addon
-- Returns: table or nil - addon info table
function AddonManager:GetAddonInfo(addonName)
    local allAddons = self:GetAllAddons()
    return allAddons[addonName]
end

