-- Core.lua
-- Main addon initialization and setup

-- Build "AddonProfiles" addon
AddonProfiles = LibStub("AceAddon-3.0"):NewAddon("AddonProfiles", "AceConsole-3.0")
AddonProfiles.ADDON_NAME = "AddonProfiles"
AddonProfiles.VERSION = "2.0.0-beta2"

-- Database defaults
local defaults = {
    global = {
        activeProfile = nil,
        profiles = {},
        settings = {
            hideDefaultAddonsButton = true  -- Hide WoW's default AddOns button by default
        }
    },
    char = {
        activeProfile = nil,
        profiles = {}
    }
}

function AddonProfiles:OnInitialize()
    -- Initialize AceDB
    self.db = LibStub("AceDB-3.0"):New("AddonProfilesDB", defaults, true)
    
    -- Migrate old data if present
    self:MigrateOldData()
    
    -- Register slash commands
    self:RegisterChatCommand("addonprofiles", "SlashHandler")
    self:RegisterChatCommand("ap", "SlashHandler")
    
    -- Print welcome message
    self:Print(string.format("v%s loaded! Type '/ap' or '/addonprofiles' to open the UI.", self.VERSION))
end

function AddonProfiles:OnEnable()
    -- Initialize UI namespace (but don't create the frame yet)
    if not self.UI then
        self.UI = {}
    end
    
    -- Initialize UI module (sets up namespace only)
    if self.UI.Initialize then
        self.UI:Initialize()
    end
    
    -- Hook GameMenuFrame to add our button when it's shown
    GameMenuFrame:HookScript("OnShow", function()
        if not self.gameMenuButtonAdded then
            self:AddGameMenuButton()
            self.gameMenuButtonAdded = true
        end
    end)
end

-- Add a button to the game menu (Escape menu)
function AddonProfiles:AddGameMenuButton()
    -- Check if button already exists
    if GameMenuButtonAddonProfiles and GameMenuButtonAddonProfiles:IsShown() then
        return
    end
    
    -- Check if we should hide the default AddOns button
    local hideDefaultButton = self.db.global.settings.hideDefaultAddonsButton
    
    -- Create the Addon Profiles button
    local button = CreateFrame("Button", "GameMenuButtonAddonProfiles", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText("Addon Profiles")
    button:SetScript("OnClick", function()
        HideUIPanel(GameMenuFrame)
        AddonProfiles:OpenUI()
    end)
    
    -- Find the reference button to position relative to
    local referenceButton = nil
    if hideDefaultButton then
        -- Hide the default AddOns button
        if GameMenuButtonAddons then
            GameMenuButtonAddons:Hide()
        end
        -- Try to find a button to position relative to (System, Options, or UIOptions)
        referenceButton = GameMenuButtonOptions or GameMenuButtonUIOptions or GameMenuButtonHelp
    else
        -- Position below AddOns button
        referenceButton = GameMenuButtonAddons
    end
    
    if referenceButton then
        button:SetPoint("TOP", referenceButton, "BOTTOM", 0, -1)
        self:Print("Addon Profiles button added to game menu")
    else
        -- Fallback: position at top of menu
        button:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10)
        self:Print("Addon Profiles button added (fallback position)")
    end
    
    -- Ensure button is shown
    button:Show()
end

-- Refresh the game menu button (called when settings change)
function AddonProfiles:RefreshGameMenuButton()
    -- Remove existing button
    if GameMenuButtonAddonProfiles then
        GameMenuButtonAddonProfiles:Hide()
        GameMenuButtonAddonProfiles = nil
    end
    
    -- Restore default AddOns button visibility
    if GameMenuButtonAddons then
        GameMenuButtonAddons:Show()
    end
    
    -- Reset flag and re-add button
    self.gameMenuButtonAdded = false
    self:AddGameMenuButton()
    self.gameMenuButtonAdded = true
end

-- MigrateOldData migrates from v1 AddonProfilesStore format to v2 AceDB format
function AddonProfiles:MigrateOldData()
    if not AddonProfilesStore or next(AddonProfilesStore) == nil then
        return -- No old data to migrate
    end
    
    local migratedCount = 0
    local playerName = UnitName("player")
    
    for profileName, addonList in pairs(AddonProfilesStore) do
        -- Check if already migrated
        if not self.db.char.profiles[profileName] then
            -- Convert array format to map format
            local addonMap = {}
            for _, addonName in ipairs(addonList) do
                addonMap[addonName] = true
            end
            
            -- Create profile in character scope
            self.db.char.profiles[profileName] = {
                addons = addonMap,
                autoDeps = true,
                scope = "character",
                created = time(),
                migrated = true
            }
            
            migratedCount = migratedCount + 1
        end
    end
    
    if migratedCount > 0 then
        self:Printf("Migrated %d profile(s) from v1 to v2 format.", migratedCount)
    end
end

-- Slash command handler
function AddonProfiles:SlashHandler(input)
    if not input or input == "" then
        self:OpenUI()
        return
    end
    
    -- Parse command and arguments
    local args = {}
    for word in input:gmatch("%S+") do
        table.insert(args, word)
    end
    
    local cmd = args[1]
    
    if cmd == "help" then
        self:ShowHelp()
    elseif cmd == "show" then
        if args[2] then
            self:ShowProfile(args[2])
        else
            self:ShowAllProfiles()
        end
    elseif cmd == "load" then
        if not args[2] then
            self:Print("Usage: /ap load <profile>")
            return
        end
        self:LoadProfile(args[2])
    elseif cmd == "save" then
        if not args[2] then
            self:Print("Usage: /ap save <profile>")
            return
        end
        self:SaveProfile(args[2])
    elseif cmd == "new" then
        if not args[2] then
            self:Print("Usage: /ap new <profile> [account|char]")
            return
        end
        local scope = args[3] == "account" and "account" or "character"
        self:NewProfile(args[2], scope)
    elseif cmd == "delete" then
        if not args[2] then
            self:Print("Usage: /ap delete <profile>")
            return
        end
        self:DeleteProfile(args[2])
    elseif cmd == "ui" then
        self:OpenUI()
    else
        self:ShowHelp()
    end
end

-- Command implementations
function AddonProfiles:ShowHelp()
    self:Print("AddonProfiles Commands:")
    self:Print("  /ap or /ap ui - Open profile manager UI")
    self:Print("  /ap show [profile] - Show all profiles or specific profile")
    self:Print("  /ap load <profile> - Activate a profile")
    self:Print("  /ap save <profile> - Save current addon state to profile")
    self:Print("  /ap new <profile> [account|char] - Create new profile")
    self:Print("  /ap delete <profile> - Delete a profile")
    self:Print("  /ap help - Show this help")
end

function AddonProfiles:ShowAllProfiles()
    local hasProfiles = false
    
    self:Print("Account-wide Profiles:")
    for name, profile in pairs(self.db.global.profiles) do
        local count = self.ProfileManager:GetProfileAddonCount(name, "account", false)
        self:Printf("  %s (%d addons)", name, count)
        hasProfiles = true
    end
    
    if not hasProfiles then
        self:Print("  (none)")
    end
    
    hasProfiles = false
    self:Print("Character Profiles:")
    for name, profile in pairs(self.db.char.profiles) do
        local count = self.ProfileManager:GetProfileAddonCount(name, "character", false)
        self:Printf("  %s (%d addons)", name, count)
        hasProfiles = true
    end
    
    if not hasProfiles then
        self:Print("  (none)")
    end
end

function AddonProfiles:ShowProfile(name)
    -- Try character scope first
    local profile = self.ProfileManager:GetProfile(name, "character")
    local scope = "character"
    
    if not profile then
        -- Try account scope
        profile = self.ProfileManager:GetProfile(name, "account")
        scope = "account"
    end
    
    if not profile then
        self:Printf("Profile '%s' not found.", name)
        return
    end
    
    local count = self.ProfileManager:GetProfileAddonCount(name, scope, false)
    local depCount = self.AddonManager:GetDependencyCount(profile.addons, profile.autoDeps)
    
    self:Printf("Profile: %s (%s scope)", name, scope)
    self:Printf("  AddOns: %d", count)
    self:Printf("  Dependencies: %d", depCount)
    self:Printf("  Auto-include deps: %s", profile.autoDeps and "Yes" or "No")
    
    -- List addons
    local addonNames = {}
    for addonName in pairs(profile.addons) do
        table.insert(addonNames, addonName)
    end
    table.sort(addonNames)
    
    if #addonNames > 0 then
        self:Print("  AddOns in profile:")
        for _, addonName in ipairs(addonNames) do
            self:Printf("    - %s", addonName)
        end
    end
end

function AddonProfiles:LoadProfile(name)
    -- Try character scope first
    local profile = self.ProfileManager:GetProfile(name, "character")
    local scope = "character"
    
    if not profile then
        -- Try account scope
        profile = self.ProfileManager:GetProfile(name, "account")
        scope = "account"
    end
    
    if not profile then
        self:Printf("Profile '%s' not found.", name)
        return
    end
    
    local success, err = self.ProfileManager:ActivateProfile(name, scope)
    
    if success then
        self:Printf("Activated profile '%s'. Reloading UI...", name)
        -- Reload UI immediately (Classic doesn't have C_Timer)
        ReloadUI()
    else
        self:Printf("Error activating profile: %s", err)
    end
end

function AddonProfiles:SaveProfile(name)
    -- Try character scope first
    local profile = self.ProfileManager:GetProfile(name, "character")
    local scope = "character"
    
    if not profile then
        -- Try account scope
        profile = self.ProfileManager:GetProfile(name, "account")
        scope = "account"
    end
    
    if not profile then
        self:Printf("Profile '%s' not found.", name)
        return
    end
    
    local success, err = self.ProfileManager:SaveCurrentState(name, scope)
    
    if success then
        local count = self.ProfileManager:GetProfileAddonCount(name, scope, false)
        self:Printf("Saved current addon state to '%s' (%d addons).", name, count)
    else
        self:Printf("Error saving profile: %s", err)
    end
end

function AddonProfiles:NewProfile(name, scope)
    local success, err = self.ProfileManager:CreateProfile(name, scope, {})
    
    if success then
        self:Printf("Created new %s profile '%s'.", scope, name)
    else
        self:Printf("Error creating profile: %s", err)
    end
end

function AddonProfiles:DeleteProfile(name)
    -- Try character scope first
    local profile = self.ProfileManager:GetProfile(name, "character")
    local scope = "character"
    
    if not profile then
        -- Try account scope
        profile = self.ProfileManager:GetProfile(name, "account")
        scope = "account"
    end
    
    if not profile then
        self:Printf("Profile '%s' not found.", name)
        return
    end
    
    local success, err = self.ProfileManager:DeleteProfile(name, scope)
    
    if success then
        self:Printf("Deleted profile '%s'.", name)
    else
        self:Printf("Error deleting profile: %s", err)
    end
end

function AddonProfiles:OpenUI()
    -- Ensure UI module exists
    if not self.UI or not self.UI.Show then
        self:Print("Error: UI module not loaded")
        return
    end
    
    -- Call Show() which handles lazy frame creation
    local success, err = pcall(function()
        self.UI:Show()
    end)
    
    if not success then
        self:Print("Error opening UI: " .. tostring(err))
        self:Print("Please report this error at: https://github.com/jmervine/AddonProfiles/issues")
    end
end
