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
    
    -- Spacing
    local spacer1 = AceGUI:Create("Label")
    spacer1:SetText(" ")
    spacer1:SetFullWidth(true)
    container:AddChild(spacer1)
    
    -- Profile list with collapsible categories
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("List")
    
    local profiles = AddonProfiles.ProfileManager:GetAllProfiles("all")
    local activeName, activeScope = AddonProfiles.ProfileManager:GetActiveProfile()
    
    -- Organize profiles by scope
    local accountProfiles = {}
    local charProfiles = {}
    
    for name, profile in pairs(profiles) do
        if profile.scope == "account" then
            table.insert(accountProfiles, name)
        else
            table.insert(charProfiles, name)
        end
    end
    
    table.sort(accountProfiles)
    table.sort(charProfiles)
    
    -- Initialize expanded state
    if self.expandedCategories == nil then
        self.expandedCategories = {
            account = true,
            character = true
        }
    end
    
    -- Account-wide category
    local accountHeader = AceGUI:Create("InteractiveLabel")
    accountHeader:SetText((self.expandedCategories.account and "[-] " or "[+] ") .. "Account-wide")
    accountHeader:SetFullWidth(true)
    accountHeader:SetCallback("OnClick", function()
        self.expandedCategories.account = not self.expandedCategories.account
        self:PopulateProfileList()
    end)
    scroll:AddChild(accountHeader)
    
    -- Spacing after header
    local headerSpacer1 = AceGUI:Create("Label")
    headerSpacer1:SetText(" ")
    headerSpacer1:SetFullWidth(true)
    scroll:AddChild(headerSpacer1)
    
    -- Account profiles
    if self.expandedCategories.account and #accountProfiles > 0 then
        for _, name in ipairs(accountProfiles) do
            local isActive = (name == activeName and "account" == activeScope)
            local isSelected = self.currentProfile and self.currentProfile.name == name and self.currentProfile.scope == "account"
            local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(name, "account", false)
            
            local profileBtn = AceGUI:Create("InteractiveLabel")
            local text = "  " .. name .. " (" .. addonCount .. ")"
            profileBtn:SetText(text)
            profileBtn:SetFullWidth(true)
            
            if isSelected then
                profileBtn:SetColor(1, 0.82, 0)  -- Gold = Selected for editing
            elseif isActive then
                profileBtn:SetColor(0, 1, 0)  -- Green = Active/Applied
            else
                profileBtn:SetColor(1, 1, 1)  -- White = Normal
            end
            
            profileBtn:SetCallback("OnClick", function()
                self:SelectProfile(name, "account")
            end)
            
            scroll:AddChild(profileBtn)
            
            -- Small spacing between profiles
            local profileSpacer = AceGUI:Create("Label")
            profileSpacer:SetText(" ")
            profileSpacer:SetFullWidth(true)
            scroll:AddChild(profileSpacer)
        end
    end
    
    -- Spacing
    local spacer2 = AceGUI:Create("Label")
    spacer2:SetText(" ")
    spacer2:SetFullWidth(true)
    scroll:AddChild(spacer2)
    
    -- Character-specific category
    if #charProfiles > 0 then
        local charName = UnitName("player")
        local charHeader = AceGUI:Create("InteractiveLabel")
        charHeader:SetText((self.expandedCategories.character and "[-] " or "[+] ") .. charName)
        charHeader:SetFullWidth(true)
        charHeader:SetCallback("OnClick", function()
            self.expandedCategories.character = not self.expandedCategories.character
            self:PopulateProfileList()
        end)
        scroll:AddChild(charHeader)
        
        -- Spacing after header
        local headerSpacer2 = AceGUI:Create("Label")
        headerSpacer2:SetText(" ")
        headerSpacer2:SetFullWidth(true)
        scroll:AddChild(headerSpacer2)
        
        -- Character profiles
        if self.expandedCategories.character then
            for _, name in ipairs(charProfiles) do
                local isActive = (name == activeName and "character" == activeScope)
                local isSelected = self.currentProfile and self.currentProfile.name == name and self.currentProfile.scope == "character"
                local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(name, "character", false)
                
                local profileBtn = AceGUI:Create("InteractiveLabel")
                local text = "  " .. name .. " (" .. addonCount .. ")"
                if isActive then
                    text = "  ✓ " .. name .. " (" .. addonCount .. ")"
                end
                profileBtn:SetText(text)
                profileBtn:SetFullWidth(true)
                
                if isSelected then
                    profileBtn:SetColor(1, 0.82, 0)  -- Gold highlight
                else
                    profileBtn:SetColor(1, 1, 1)  -- White
                end
                
                profileBtn:SetCallback("OnClick", function()
                    self:SelectProfile(name, "character")
                end)
                
                scroll:AddChild(profileBtn)
                
                -- Small spacing between profiles
                local profileSpacer = AceGUI:Create("Label")
                profileSpacer:SetText(" ")
                profileSpacer:SetFullWidth(true)
                scroll:AddChild(profileSpacer)
            end
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
        account = "Account-wide",
        character = "Character-specific"
    })
    scopeDropdown:SetValue("account")  -- Default to account-wide
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

-- ConfirmDeleteProfile moved to ProfileSettings.lua

