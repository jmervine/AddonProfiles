-- UI/ProfileSettings.lua
-- Right panel: Profile settings and actions

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")
local UI = AddonProfiles.UI

function UI:PopulateSettings()
    -- Safety checks
    if not self.RightPanel then
        return
    end
    
    if not AddonProfiles.ProfileManager or not AddonProfiles.AddonManager then
        return
    end
    
    -- Clear existing content
    self.RightPanel:ReleaseChildren()
    
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("List")
    
    -- Get selected profile
    local profileName, profileScope, profile = self:GetSelectedProfile()
    
    if not profile then
        local noSelection = AceGUI:Create("Label")
        noSelection:SetText("Select a profile to edit settings")
        noSelection:SetFullWidth(true)
        container:AddChild(noSelection)
        self.RightPanel:AddChild(container)
        return
    end
    
    -- Profile name
    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("Profile Name:")
    nameLabel:SetFullWidth(true)
    container:AddChild(nameLabel)
    
    local nameBox = AceGUI:Create("EditBox")
    nameBox:SetFullWidth(true)
    nameBox:SetText(profileName)
    nameBox:SetCallback("OnEnterPressed", function(widget, event, text)
        if text and text ~= "" and text ~= profileName then
            local success, err = AddonProfiles.ProfileManager:RenameProfile(profileName, text, profileScope)
            if success then
                AddonProfiles:Printf("Renamed profile to '%s'.", text)
                self:SelectProfile(text, profileScope)
            else
                AddonProfiles:Printf("Error: %s", err)
                nameBox:SetText(profileName) -- Reset on error
            end
        end
    end)
    container:AddChild(nameBox)
    
    -- Spacing
    local spacer1 = AceGUI:Create("Label")
    spacer1:SetText(" ")
    spacer1:SetFullWidth(true)
    container:AddChild(spacer1)
    
    -- Scope display (read-only)
    local scopeLabel = AceGUI:Create("Label")
    scopeLabel:SetText("Scope:")
    scopeLabel:SetFullWidth(true)
    container:AddChild(scopeLabel)
    
    local scopeValue = AceGUI:Create("Label")
    scopeValue:SetText(profile.scope == "account" and "Account-wide" or "Character-specific")
    scopeValue:SetFullWidth(true)
    scopeValue:SetColor(0.8, 0.8, 0.8)
    container:AddChild(scopeValue)
    
    -- Spacing
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetText(" ")
    spacer2:SetFullWidth(true)
    container:AddChild(spacer2)
    
    -- Auto-include dependencies checkbox
    local autoDepsCheck = AceGUI:Create("CheckBox")
    autoDepsCheck:SetLabel("Auto-include dependencies")
    autoDepsCheck:SetValue(profile.autoDeps)
    autoDepsCheck:SetFullWidth(true)
    autoDepsCheck:SetCallback("OnValueChanged", function(widget, event, value)
        profile.autoDeps = value
        self:PopulateAddonList() -- Refresh addon list to show/hide dep graying
        self:PopulateSettings() -- Refresh to update dep count
    end)
    container:AddChild(autoDepsCheck)
    
    -- Dependency count display
    local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(profileName, profileScope, false)
    local depCount = AddonProfiles.AddonManager:GetDependencyCount(profile.addons, profile.autoDeps)
    
    local countLabel = AceGUI:Create("Label")
    countLabel:SetText(string.format("Addons: %d\nDependencies: +%d\nTotal: %d", 
        addonCount, depCount, addonCount + depCount))
    countLabel:SetFullWidth(true)
    countLabel:SetColor(0.7, 0.7, 0.7)
    container:AddChild(countLabel)
    
    -- Spacing
    local spacer3 = AceGUI:Create("Label")
    spacer3:SetText(" ")
    spacer3:SetFullWidth(true)
    container:AddChild(spacer3)
    
    -- Save Profile button (to make it clear changes are saved)
    local saveBtn = AceGUI:Create("Button")
    saveBtn:SetText("Save Profile")
    saveBtn:SetFullWidth(true)
    saveBtn:SetCallback("OnClick", function()
        -- Profile changes are auto-saved, this just confirms
        AddonProfiles:Printf("Profile '%s' saved successfully.", profileName)
        self:Refresh()
    end)
    container:AddChild(saveBtn)
    
    -- Spacing
    local spacer3b = AceGUI:Create("Label")
    spacer3b:SetText(" ")
    spacer3b:SetFullWidth(true)
    container:AddChild(spacer3b)
    
    -- Action buttons
    local applyBtn = AceGUI:Create("Button")
    applyBtn:SetText("Apply Profile")
    applyBtn:SetFullWidth(true)
    applyBtn:SetCallback("OnClick", function()
        self:ApplyProfile(profileName, profileScope)
    end)
    container:AddChild(applyBtn)
    
    -- Check if this is the active profile
    local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
    if profileName == activeName and profileScope == activeScope then
        local activeLabel = AceGUI:Create("Label")
        activeLabel:SetText("✓ Currently Active")
        activeLabel:SetFullWidth(true)
        activeLabel:SetColor(0, 1, 0)
        container:AddChild(activeLabel)
    end
    
    -- Spacing
    local spacer4 = AceGUI:Create("Label")
    spacer4:SetText(" ")
    spacer4:SetFullWidth(true)
    container:AddChild(spacer4)
    
    local captureBtn = AceGUI:Create("Button")
    captureBtn:SetText("Select Active Addons")
    captureBtn:SetFullWidth(true)
    captureBtn:SetCallback("OnClick", function()
        local success, err = AddonProfiles.ProfileManager:SaveCurrentState(profileName, profileScope)
        if success then
            AddonProfiles:Print("Selected currently active addons.")
            self:Refresh()
        else
            AddonProfiles:Printf("Error: %s", err)
        end
    end)
    container:AddChild(captureBtn)
    
    -- Spacing
    local spacer5 = AceGUI:Create("Label")
    spacer5:SetText(" ")
    spacer5:SetFullWidth(true)
    container:AddChild(spacer5)
    
    -- Copy Profile button
    local copyBtn = AceGUI:Create("Button")
    copyBtn:SetText("Copy Profile")
    copyBtn:SetFullWidth(true)
    copyBtn:SetCallback("OnClick", function()
        self:ShowCopyProfileDialog(profileName, profileScope)
    end)
    container:AddChild(copyBtn)
    
    -- Delete Profile button
    local deleteBtn = AceGUI:Create("Button")
    deleteBtn:SetText("Delete Profile")
    deleteBtn:SetFullWidth(true)
    deleteBtn:SetCallback("OnClick", function()
        self:ConfirmDeleteProfile(profileName, profileScope)
    end)
    container:AddChild(deleteBtn)
    
    self.RightPanel:AddChild(container)
end

function UI:ShowCopyProfileDialog(sourceProfileName, sourceProfileScope)
    -- Create dialog for copying profile
    local dialog = AceGUI:Create("Frame")
    dialog:SetTitle("Copy Profile")
    dialog:SetStatusText("Create a copy of '" .. sourceProfileName .. "'")
    dialog:SetLayout("Flow")
    dialog:SetWidth(400)
    dialog:SetHeight(280)
    
    -- New profile name input
    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("New Profile Name:")
    nameLabel:SetFullWidth(true)
    dialog:AddChild(nameLabel)
    
    local nameInput = AceGUI:Create("EditBox")
    nameInput:SetFullWidth(true)
    nameInput:SetText(sourceProfileName .. " Copy")
    dialog:AddChild(nameInput)
    
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
        account = "Account-wide",
        character = "Character-specific"
    })
    scopeDropdown:SetValue(sourceProfileScope)  -- Default to same scope as source
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
    createBtn:SetText("Copy")
    createBtn:SetWidth(150)
    createBtn:SetCallback("OnClick", function()
        local newName = nameInput:GetText()
        local newScope = scopeDropdown:GetValue()
        
        if not newName or newName == "" then
            AddonProfiles:Print("Profile name cannot be empty.")
            return
        end
        
        -- Get source profile data
        local sourceProfile = AddonProfiles.ProfileManager:GetProfile(sourceProfileName, sourceProfileScope)
        if not sourceProfile then
            AddonProfiles:Printf("Error: Source profile '%s' not found.", sourceProfileName)
            dialog:Release()
            return
        end
        
        -- Create new profile with copied data
        local success, err = AddonProfiles.ProfileManager:CreateProfile(newName, newScope)
        if not success then
            AddonProfiles:Printf("Error: %s", err)
            return
        end
        
        -- Copy all addons and settings
        local newProfile = AddonProfiles.ProfileManager:GetProfile(newName, newScope)
        if newProfile then
            -- Copy addons
            for addonName, enabled in pairs(sourceProfile.addons or {}) do
                newProfile.addons[addonName] = enabled
            end
            -- Copy settings
            newProfile.autoDependencies = sourceProfile.autoDependencies
        end
        
        AddonProfiles:Printf("Created profile '%s' as a copy of '%s'.", newName, sourceProfileName)
        
        -- Select the new profile
        self:SelectProfile(newName, newScope)
        
        dialog:Release()
    end)
    btnGroup:AddChild(createBtn)
    
    local cancelBtn = AceGUI:Create("Button")
    cancelBtn:SetText("Cancel")
    cancelBtn:SetWidth(150)
    cancelBtn:SetCallback("OnClick", function()
        dialog:Release()
    end)
    btnGroup:AddChild(cancelBtn)
    
    dialog:AddChild(btnGroup)
    
    -- Cleanup
    dialog:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
    end)
end

function UI:ConfirmDeleteProfile(profileName, profileScope)
    -- Temporarily hide main frame so dialog appears on top
    local wasShown = self.MainFrame and self.MainFrame:IsShown()
    if wasShown then
        self.MainFrame:Hide()
    end
    
    -- Confirmation dialog
    StaticPopupDialogs["ADDONPROFILES_DELETE_CONFIRM"] = {
        text = string.format("Delete profile '%s'?", profileName),
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function()
            local success, err = AddonProfiles.ProfileManager:DeleteProfile(profileName, profileScope)
            if success then
                AddonProfiles:Printf("Deleted profile '%s'.", profileName)
                -- Clear selection and refresh
                self.currentProfile = nil
                self:Refresh()
            else
                AddonProfiles:Printf("Error: %s", err)
            end
            if wasShown then
                self.MainFrame:Show()
            end
        end,
        OnCancel = function()
            if wasShown then
                self.MainFrame:Show()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS
    }
    StaticPopup_Show("ADDONPROFILES_DELETE_CONFIRM")
end

function UI:ApplyProfile(profileName, profileScope)
    -- Temporarily hide main frame so dialog appears on top
    local wasShown = self.MainFrame and self.MainFrame:IsShown()
    if wasShown then
        self.MainFrame:Hide()
    end
    
    -- Confirmation dialog
    StaticPopupDialogs["ADDONPROFILES_APPLY_CONFIRM"] = {
        text = string.format("Apply profile '%s'?\n\nThis will reload the UI.", profileName),
        button1 = "Apply",
        button2 = "Cancel",
        OnAccept = function()
            local success, err = AddonProfiles.ProfileManager:ActivateProfile(profileName, profileScope)
            if success then
                -- Reload UI immediately (Classic doesn't have C_Timer)
                ReloadUI()
            else
                AddonProfiles:Printf("Error: %s", err)
                if wasShown then
                    self.MainFrame:Show()
                end
            end
        end,
        OnCancel = function()
            if wasShown then
                self.MainFrame:Show()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS
    }
    StaticPopup_Show("ADDONPROFILES_APPLY_CONFIRM")
end

