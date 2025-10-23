-- UI/MainFrame.lua
-- Main frame for the addon profile manager UI

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")

AddonProfiles.UI = AddonProfiles.UI or {}
local UI = AddonProfiles.UI

UI.currentProfile = nil -- { name = "...", scope = "..." }
UI.currentScope = "character" -- Filter for profile list

function UI:Initialize()
    -- Create main frame on first call
    if not self.MainFrame then
        self:CreateMainFrame()
    end
end

function UI:CreateMainFrame()
    -- Create main window
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Addon Profiles")
    frame:SetStatusText("AddonProfiles v" .. AddonProfiles.VERSION)
    frame:SetLayout("Fill")
    frame:SetWidth(900)
    frame:SetHeight(600)
    
    -- Store reference
    self.MainFrame = frame
    
    -- Create main container with three columns
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("Flow")
    
    -- Left panel (Profile List) - 250px width
    local leftPanel = AceGUI:Create("InlineGroup")
    leftPanel:SetTitle("Profiles")
    leftPanel:SetWidth(250)
    leftPanel:SetFullHeight(true)
    leftPanel:SetLayout("Fill")
    
    -- Middle panel (Addon List) - 400px width
    local middlePanel = AceGUI:Create("InlineGroup")
    middlePanel:SetTitle("Addons")
    middlePanel:SetWidth(400)
    middlePanel:SetFullHeight(true)
    middlePanel:SetLayout("Fill")
    
    -- Right panel (Profile Settings) - 250px width
    local rightPanel = AceGUI:Create("InlineGroup")
    rightPanel:SetTitle("Settings")
    rightPanel:SetWidth(230)
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
    
    -- Populate panels
    self:PopulateProfileList()
    self:PopulateAddonList()
    self:PopulateSettings()
    
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
    
    self:PopulateProfileList()
    self:PopulateAddonList()
    self:PopulateSettings()
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

-- Initialize UI when addon loads
AddonProfiles.UI:Initialize()

