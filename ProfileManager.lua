-- ProfileManager.lua
-- Handles profile CRUD operations and profile activation

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local ProfileManager = {}
AddonProfiles.ProfileManager = ProfileManager

-- CreateProfile creates a new profile with the given name and scope
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
--   initialAddons: table (optional) - { [addonName] = true } map
-- Returns: boolean, string - success status and error message
function ProfileManager:CreateProfile(name, scope, initialAddons)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    if scope ~= "account" and scope ~= "character" then
        return false, "Scope must be 'account' or 'character'"
    end
    
    -- Check if profile already exists
    local db = scope == "account" and AddonProfiles.db.global or AddonProfiles.db.char
    
    if db.profiles[name] then
        return false, "Profile already exists"
    end
    
    -- Create profile
    db.profiles[name] = {
        addons = initialAddons or {},
        autoDeps = true,
        scope = scope,
        created = time()
    }
    
    return true
end

-- DeleteProfile removes a profile
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
-- Returns: boolean, string - success status and error message
function ProfileManager:DeleteProfile(name, scope)
    if not name or name == "" then
        return false, "Profile name cannot be empty"
    end
    
    if scope ~= "account" and scope ~= "character" then
        return false, "Invalid scope"
    end
    
    local db = scope == "account" and AddonProfiles.db.global or AddonProfiles.db.char
    
    if not db.profiles[name] then
        return false, "Profile not found"
    end
    
    -- Don't delete if it's the active profile
    if db.activeProfile == name then
        db.activeProfile = nil
    end
    
    db.profiles[name] = nil
    return true
end

-- GetProfile retrieves a profile by name and scope
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
-- Returns: table or nil - profile data
function ProfileManager:GetProfile(name, scope)
    if not name or not scope then
        return nil
    end
    
    local db = scope == "account" and AddonProfiles.db.global or AddonProfiles.db.char
    return db.profiles[name]
end

-- GetAllProfiles returns all profiles for the given scope
-- Parameters:
--   scope: string - "account", "character", or "all"
-- Returns: table - { [name] = profile }
function ProfileManager:GetAllProfiles(scope)
    local profiles = {}
    
    if scope == "account" or scope == "all" then
        for name, profile in pairs(AddonProfiles.db.global.profiles) do
            profiles[name] = profile
        end
    end
    
    if scope == "character" or scope == "all" then
        for name, profile in pairs(AddonProfiles.db.char.profiles) do
            profiles[name] = profile
        end
    end
    
    return profiles
end

-- UpdateProfile updates an existing profile
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
--   updates: table - fields to update { addons, autoDeps }
-- Returns: boolean, string - success status and error message
function ProfileManager:UpdateProfile(name, scope, updates)
    if not name or not scope then
        return false, "Invalid parameters"
    end
    
    local profile = self:GetProfile(name, scope)
    if not profile then
        return false, "Profile not found"
    end
    
    if updates.addons ~= nil then
        profile.addons = updates.addons
    end
    
    if updates.autoDeps ~= nil then
        profile.autoDeps = updates.autoDeps
    end
    
    return true
end

-- ActivateProfile applies a profile (enables/disables addons accordingly)
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
-- Returns: boolean, string - success status and error message
function ProfileManager:ActivateProfile(name, scope)
    local profile = self:GetProfile(name, scope)
    
    if not profile then
        return false, "Profile not found"
    end
    
    local addonManager = AddonProfiles.AddonManager
    
    -- Resolve dependencies if needed
    local addonsToEnable = addonManager:ResolveDependencies(profile.addons, profile.autoDeps)
    
    -- Get all addons to determine what to disable
    local allAddons = addonManager:GetAllAddons()
    
    -- Disable all addons first, except AddonProfiles itself
    for addonName, _ in pairs(allAddons) do
        if addonName ~= "AddonProfiles" then
            AddonProfiles.AddonManager:DisableAddOn(addonName)
        end
    end
    
    -- Enable addons in profile
    addonManager:EnableAddons(addonsToEnable)
    
    -- Always enable AddonProfiles itself
    AddonProfiles.AddonManager:EnableAddOn("AddonProfiles")
    
    -- Set as active profile
    local db = scope == "account" and AddonProfiles.db.global or AddonProfiles.db.char
    db.activeProfile = name
    
    return true
end

-- GetActiveProfile returns the currently active profile name and scope
-- Returns: string, string - profile name, scope (or nil, nil if none active)
function ProfileManager:GetActiveProfile()
    -- Check character scope first
    if AddonProfiles.db.char.activeProfile then
        return AddonProfiles.db.char.activeProfile, "character"
    end
    
    -- Then check account scope
    if AddonProfiles.db.global.activeProfile then
        return AddonProfiles.db.global.activeProfile, "account"
    end
    
    return nil, nil
end

-- SaveCurrentState saves the current addon state to a profile
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
-- Returns: boolean, string - success status and error message
function ProfileManager:SaveCurrentState(name, scope)
    local profile = self:GetProfile(name, scope)
    
    if not profile then
        return false, "Profile not found"
    end
    
    -- Get currently enabled addons
    local addonManager = AddonProfiles.AddonManager
    local allAddons = addonManager:GetAllAddons()
    local enabledAddons = {}
    
    for addonName, info in pairs(allAddons) do
        if info.enabled then
            enabledAddons[addonName] = true
        end
    end
    
    profile.addons = enabledAddons
    
    return true
end

-- RenameProfile renames a profile
-- Parameters:
--   oldName: string - current profile name
--   newName: string - new profile name
--   scope: string - "account" or "character"
-- Returns: boolean, string - success status and error message
function ProfileManager:RenameProfile(oldName, newName, scope)
    if not oldName or not newName or not scope then
        return false, "Invalid parameters"
    end
    
    if oldName == newName then
        return true -- Nothing to do
    end
    
    local db = scope == "account" and AddonProfiles.db.global or AddonProfiles.db.char
    
    if not db.profiles[oldName] then
        return false, "Profile not found"
    end
    
    if db.profiles[newName] then
        return false, "A profile with the new name already exists"
    end
    
    -- Copy to new name
    db.profiles[newName] = db.profiles[oldName]
    db.profiles[oldName] = nil
    
    -- Update active profile reference if needed
    if db.activeProfile == oldName then
        db.activeProfile = newName
    end
    
    return true
end

-- GetProfileAddonCount returns the number of addons in a profile
-- Parameters:
--   name: string - profile name
--   scope: string - "account" or "character"
--   includeDeps: boolean - whether to include dependencies in count
-- Returns: number - addon count
function ProfileManager:GetProfileAddonCount(name, scope, includeDeps)
    local profile = self:GetProfile(name, scope)
    
    if not profile then
        return 0
    end
    
    if includeDeps and profile.autoDeps then
        local addonManager = AddonProfiles.AddonManager
        local resolved = addonManager:ResolveDependencies(profile.addons, true)
        local count = 0
        for _ in pairs(resolved) do
            count = count + 1
        end
        return count
    else
        local count = 0
        for _ in pairs(profile.addons) do
            count = count + 1
        end
        return count
    end
end

