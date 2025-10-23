-- UI/MainFrame.lua
-- Main frame for the addon profile manager UI

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")

AddonProfiles.UI = AddonProfiles.UI or {}
local UI = AddonProfiles.UI

UI.currentProfile = nil -- { name = "...", scope = "..." }
UI.currentScope = "character" -- Filter for profile list

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
    
    -- Create main container with three columns using relative widths
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("Flow")
    
    -- Left panel (Profile List) - 27% relative width
    local leftPanel = AceGUI:Create("InlineGroup")
    leftPanel:SetTitle("Profiles")
    leftPanel:SetRelativeWidth(0.27)
    leftPanel:SetFullHeight(true)
    leftPanel:SetLayout("Fill")
    
    -- Middle panel (Addon List) - 44% relative width  
    local middlePanel = AceGUI:Create("InlineGroup")
    middlePanel:SetTitle("Addons")
    middlePanel:SetRelativeWidth(0.44)
    middlePanel:SetFullHeight(true)
    middlePanel:SetLayout("Fill")
    
    -- Right panel (Profile Settings) - 27% relative width
    local rightPanel = AceGUI:Create("InlineGroup")
    rightPanel:SetTitle("Settings")
    rightPanel:SetRelativeWidth(0.27)
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
    
    -- Populate panels (with error handling)
    local success, err = pcall(function()
        self:PopulateProfileList()
        self:PopulateAddonList()
        self:PopulateSettings()
    end)
    
    if not success then
        AddonProfiles:Print("Error populating UI: " .. tostring(err))
    end
    
    -- Hide by default
    frame:Hide()
    
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
    
    local profile = AddonProfiles.ProfileManager:GetProfile(
        self.currentProfile.name,
        self.currentProfile.scope
    )
    
    if profile then
        return self.currentProfile.name, self.currentProfile.scope, profile
    end
    
    return nil
end

-- Note: UI initialization is now handled in Core.lua OnEnable()
-- Do NOT initialize here as it's too early in the load process

