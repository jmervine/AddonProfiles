-- UI/ProfileList.lua
-- Left panel: Profile list and management

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")
local UI = AddonProfiles.UI

function UI:PopulateProfileList()
    -- Safety checks
    if not self.LeftPanel then
        return
    end
    
    if not AddonProfiles.db then
        AddonProfiles:Print("Database not initialized")
        return
    end
    
    if not AddonProfiles.ProfileManager then
        AddonProfiles:Print("ProfileManager not loaded")
        return
    end
    
    -- Clear existing content
    self.LeftPanel:ReleaseChildren()
    
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("List")
    
    -- New Profile button
    local newButton = AceGUI:Create("Button")
    newButton:SetText("New Profile")
    newButton:SetFullWidth(true)
    newButton:SetCallback("OnClick", function()
        self:ShowNewProfileDialog()
    end)
    container:AddChild(newButton)
    
    -- Legend label
    local legendLabel = AceGUI:Create("Label")
    legendLabel:SetText("[A]=Account  [C]=Character")
    legendLabel:SetFullWidth(true)
    legendLabel:SetColor(0.7, 0.7, 0.7)
    container:AddChild(legendLabel)
    
    -- Spacing
    local spacer1 = AceGUI:Create("Label")
    spacer1:SetText(" ")
    spacer1:SetFullWidth(true)
    container:AddChild(spacer1)
    
    -- Profile list (scrollable)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetLayout("List")
    
    -- Get all profiles (both account and character)
    local profiles = AddonProfiles.ProfileManager:GetAllProfiles("all")
    
    -- Get active profile
    local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
    
    -- Sort profile names
    local profileNames = {}
    for name in pairs(profiles) do
        table.insert(profileNames, name)
    end
    table.sort(profileNames)
    
    if #profileNames == 0 then
        local noProfiles = AceGUI:Create("Label")
        noProfiles:SetText("No profiles")
        noProfiles:SetFullWidth(true)
        scroll:AddChild(noProfiles)
    else
        for _, name in ipairs(profileNames) do
            local profile = profiles[name]
            local isActive = (name == activeName and profile.scope == activeScope)
            
            -- Profile button container
            local profileRow = AceGUI:Create("SimpleGroup")
            profileRow:SetFullWidth(true)
            profileRow:SetLayout("Flow")
            
            -- Profile select button with scope indicator
            local selectBtn = AceGUI:Create("Button")
            local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(name, profile.scope, false)
            local scopeLabel = profile.scope == "account" and "[A]" or "[C]"
            local btnText = scopeLabel .. " " .. name
            if isActive then
                btnText = "✓ " .. btnText
            end
            btnText = btnText .. " (" .. addonCount .. ")"
            
            selectBtn:SetText(btnText)
            selectBtn:SetWidth(180)
            selectBtn:SetCallback("OnClick", function()
                self:SelectProfile(name, profile.scope)
            end)
            
            -- Highlight if selected
            if self.currentProfile and self.currentProfile.name == name and self.currentProfile.scope == profile.scope then
                selectBtn:SetDisabled(true)
            end
            
            profileRow:AddChild(selectBtn)
            
            -- Delete button
            local delBtn = AceGUI:Create("Button")
            delBtn:SetText("X")
            delBtn:SetWidth(30)
            delBtn:SetCallback("OnClick", function()
                self:ConfirmDeleteProfile(name, profile.scope)
            end)
            profileRow:AddChild(delBtn)
            
            scroll:AddChild(profileRow)
        end
    end
    
    container:AddChild(scroll)
    self.LeftPanel:AddChild(container)
end

function UI:ShowNewProfileDialog()
    -- Create dialog
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("New Profile")
    dialog:SetWidth(350)
    dialog:SetHeight(200)
    dialog:SetLayout("Flow")
    
    -- Profile name
    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("Profile Name:")
    nameLabel:SetFullWidth(true)
    dialog:AddChild(nameLabel)
    
    local nameBox = AceGUI:Create("EditBox")
    nameBox:SetFullWidth(true)
    nameBox:SetLabel("")
    dialog:AddChild(nameBox)
    
    -- Spacing
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    dialog:AddChild(spacer)
    
    -- Scope selection
    local scopeLabel = AceGUI:Create("Label")
    scopeLabel:SetText("Scope:")
    scopeLabel:SetFullWidth(true)
    dialog:AddChild(scopeLabel)
    
    local scopeDropdown = AceGUI:Create("Dropdown")
    scopeDropdown:SetFullWidth(true)
    scopeDropdown:SetList({
        character = "Character-specific",
        account = "Account-wide"
    })
    scopeDropdown:SetValue(self.currentScope)
    dialog:AddChild(scopeDropdown)
    
    -- Spacing
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetText(" ")
    spacer2:SetFullWidth(true)
    dialog:AddChild(spacer2)
    
    -- Buttons
    local btnGroup = AceGUI:Create("SimpleGroup")
    btnGroup:SetFullWidth(true)
    btnGroup:SetLayout("Flow")
    
    local createBtn = AceGUI:Create("Button")
    createBtn:SetText("Create")
    createBtn:SetWidth(150)
    createBtn:SetCallback("OnClick", function()
        local name = nameBox:GetText()
        local scope = scopeDropdown:GetValue()
        
        if not name or name == "" then
            AddonProfiles:Print("Profile name cannot be empty.")
            return
        end
        
        local success, err = AddonProfiles.ProfileManager:CreateProfile(name, scope, {})
        
        if success then
            AddonProfiles:Printf("Created profile '%s'.", name)
            self.currentScope = scope
            self:SelectProfile(name, scope)
            dialog:Hide()
        else
            AddonProfiles:Printf("Error: %s", err)
        end
    end)
    btnGroup:AddChild(createBtn)
    
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText("Cancel")
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        dialog:Hide()
    end)
    btnGroup:AddChild(cancelBtn)
    
    dialog:AddChild(btnGroup)
    
    -- Cleanup on close
    dialog:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
end

function UI:ConfirmDeleteProfile(name, scope)
    -- Simple confirmation dialog
    StaticPopupDialogs["ADDONPROFILES_DELETE_CONFIRM"] = {
        text = string.format("Delete profile '%s'?", name),
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function()
            local success, err = AddonProfiles.ProfileManager:DeleteProfile(name, scope)
            if success then
                AddonProfiles:Printf("Deleted profile '%s'.", name)
                if self.currentProfile and self.currentProfile.name == name and self.currentProfile.scope == scope then
                    self.currentProfile = nil
                end
                self:Refresh()
            else
                AddonProfiles:Printf("Error: %s", err)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopup_Show("ADDONPROFILES_DELETE_CONFIRM")
end

