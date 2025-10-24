-- UI/MainFrame.lua
-- Main frame for the addon profile manager UI

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")

AddonProfiles.UI = AddonProfiles.UI or {}
local UI = AddonProfiles.UI

UI.currentProfile = nil -- { name = "...", scope = "..." }

function UI:Initialize()
    -- Just set up namespace, don't create frame yet
    -- Frame will be created lazily when Show() is called
    self.initialized = true
end

function UI:CreateMainFrame()
    -- Create main window (make it resizable)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Addon Profiles")
    frame:SetStatusText("AddonProfiles v" .. AddonProfiles.VERSION)
    frame:SetLayout("Fill")
    frame:SetWidth(950)
    frame:SetHeight(650)
    
    -- Store reference
    self.MainFrame = frame
    
    -- Create main container with three columns using relative widths that sum to 1.0
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("Flow")
    
    -- Left panel (Profile List) - 28% relative width
    local leftPanel = AceGUI:Create("InlineGroup")
    leftPanel:SetTitle("Profiles")
    leftPanel:SetRelativeWidth(0.28)
    leftPanel:SetFullHeight(true)
    leftPanel:SetLayout("Fill")
    
    -- Middle panel (Addon List) - 44% relative width  
    local middlePanel = AceGUI:Create("InlineGroup")
    middlePanel:SetTitle("Addons")
    middlePanel:SetRelativeWidth(0.44)
    middlePanel:SetFullHeight(true)
    middlePanel:SetLayout("Fill")
    
    -- Right panel (Profile Settings) - 28% relative width (sums to 1.0)
    local rightPanel = AceGUI:Create("InlineGroup")
    rightPanel:SetTitle("Settings")
    rightPanel:SetRelativeWidth(0.28)
    rightPanel:SetFullHeight(true)
    rightPanel:SetLayout("Fill")
    
    -- Store panel references
    self.LeftPanel = leftPanel
    self.MiddlePanel = middlePanel
    self.RightPanel = rightPanel
    
    -- Add panels to container
    container:AddChild(leftPanel)
    container:AddChild(middlePanel)
    container:AddChild(rightPanel)
    
    -- Add container to main frame
    frame:AddChild(container)
    
    -- Select active profile by default if none is selected
    if not self.currentProfile then
        local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
        if activeName and activeScope then
            self.currentProfile = { name = activeName, scope = activeScope }
        end
    end
    
    -- Populate panels (with error handling)
    local success, err = pcall(function()
        self:PopulateProfileList()
        self:PopulateAddonList()
        self:PopulateSettings()
    end)
    
    if not success then
        AddonProfiles:Print("Error populating UI: " .. tostring(err))
    end
    
    -- Force layout recalculation to fix initial sizing issue
    container:DoLayout()
    frame:DoLayout()
    
    -- Hide by default
    frame:Hide()
    
    -- Enable Escape key to close window
    -- Add to UISpecialFrames so Escape key closes it
    table.insert(UISpecialFrames, frame.frame:GetName())
    
    -- Callback when frame is closed
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        self.MainFrame = nil
    end)
end

function UI:Show()
    if not self.MainFrame then
        self:CreateMainFrame()
    end
    self.MainFrame:Show()
end

function UI:Refresh()
    if not self.MainFrame then
        return
    end
    
    -- Only refresh if panels exist
    if not self.LeftPanel or not self.MiddlePanel or not self.RightPanel then
        return
    end
    
    local success, err = pcall(function()
        self:PopulateProfileList()
        self:PopulateAddonList()
        self:PopulateSettings()
    end)
    
    if not success then
        AddonProfiles:Print("Error refreshing UI: " .. tostring(err))
    end
end

function UI:SelectProfile(name, scope)
    self.currentProfile = { name = name, scope = scope }
    self:Refresh()
end

function UI:GetSelectedProfile()
    if not self.currentProfile then
        return nil
    end
    
    local profile
    
    -- Check if this is a profile from another character
    if self.currentProfile.charKey and self.currentProfile.scope == "character" then
        -- Fetch from other character's database
        if AddonProfiles.db.sv.char and AddonProfiles.db.sv.char[self.currentProfile.charKey] then
            profile = AddonProfiles.db.sv.char[self.currentProfile.charKey].profiles[self.currentProfile.name]
        end
    else
        -- Fetch from current character using ProfileManager
        profile = AddonProfiles.ProfileManager:GetProfile(
            self.currentProfile.name,
            self.currentProfile.scope
        )
    end
    
    if profile then
        return self.currentProfile.name, self.currentProfile.scope, profile
    end
    
    return nil
end

-- Note: UI initialization is now handled in Core.lua OnEnable()
-- Do NOT initialize here as it's too early in the load process

