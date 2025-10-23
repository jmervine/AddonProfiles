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
    
    -- Hierarchical profile tree
    local treeGroup = AceGUI:Create("TreeGroup")
    treeGroup:SetFullWidth(true)
    treeGroup:SetFullHeight(true)
    treeGroup:SetLayout("Fill")
    
    -- Build tree structure
    local tree = {}
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
    
    -- Add Account-wide category
    if #accountProfiles > 0 then
        table.insert(tree, {
            value = "account",
            text = "Account-wide",
            children = {}
        })
        
        for _, name in ipairs(accountProfiles) do
            local isActive = (name == activeName and "account" == activeScope)
            local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(name, "account", false)
            local text = name .. " (" .. addonCount .. ")"
            if isActive then
                text = "✓ " .. text
            end
            
            table.insert(tree[#tree].children, {
                value = "account:" .. name,
                text = text
            })
        end
    end
    
    -- Add Character-specific category
    if #charProfiles > 0 then
        local charName = UnitName("player")
        table.insert(tree, {
            value = "character",
            text = charName,
            children = {}
        })
        
        for _, name in ipairs(charProfiles) do
            local isActive = (name == activeName and "character" == activeScope)
            local addonCount = AddonProfiles.ProfileManager:GetProfileAddonCount(name, "character", false)
            local text = name .. " (" .. addonCount .. ")"
            if isActive then
                text = "✓ " .. text
            end
            
            table.insert(tree[#tree].children, {
                value = "character:" .. name,
                text = text
            })
        end
    end
    
    treeGroup:SetTree(tree)
    
    -- Initialize tree state if not exists
    if not self.treeStatus then
        self.treeStatus = {
            groups = {
                account = true,    -- Expanded by default
                character = true   -- Expanded by default
            }
        }
    end
    
    -- Restore tree expanded state
    treeGroup:SetStatusTable(self.treeStatus)
    
    -- Handle profile selection
    treeGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        AddonProfiles:Printf("TreeGroup selected: %s", tostring(group))
        
        -- Store tree status before processing selection
        self.treeStatus = treeGroup:GetStatusTable()
        
        -- Check if it's a profile (has colon) vs a category
        if group:find(":") then
            local scope, name = group:match("([^:]+):(.+)")
            AddonProfiles:Printf("Selecting profile: %s (scope: %s)", name, scope)
            self:SelectProfile(name, scope)
        else
            AddonProfiles:Printf("Category selected (ignored): %s", group)
        end
    end)
    
    -- Select current profile if any
    if self.currentProfile then
        local value = self.currentProfile.scope .. ":" .. self.currentProfile.name
        treeGroup:SelectByValue(value)
    end
    
    container:AddChild(treeGroup)
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

