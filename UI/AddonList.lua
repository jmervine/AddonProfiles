-- UI/AddonList.lua
-- Middle panel: Addon selection with checkboxes

local AddonProfiles = LibStub("AceAddon-3.0"):GetAddon("AddonProfiles")
local AceGUI = LibStub("AceGUI-3.0")
local UI = AddonProfiles.UI

UI.searchText = ""
UI.showOnlyCompatible = false

function UI:PopulateAddonList()
    -- Safety checks
    if not self.MiddlePanel then
        return
    end
    
    if not AddonProfiles.AddonManager then
        AddonProfiles:Print("AddonManager not loaded")
        return
    end
    
    -- Clear existing content
    self.MiddlePanel:ReleaseChildren()
    
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetFullHeight(true)
    container:SetLayout("List")
    
    -- Get selected profile
    local profileName, profileScope, profile = self:GetSelectedProfile()
    
    if not profile then
        local noSelection = AceGUI:Create("Label")
        noSelection:SetText("Select a profile to view addons")
        noSelection:SetFullWidth(true)
        container:AddChild(noSelection)
        self.MiddlePanel:AddChild(container)
        return
    end
    
    -- Check if this is a read-only profile from another character
    local isReadOnly = self.currentProfile and self.currentProfile.readOnly
    
    -- Search box
    local searchBox = AceGUI:Create("EditBox")
    searchBox:SetLabel("Search")
    searchBox:SetFullWidth(true)
    searchBox:SetText(self.searchText or "")
    searchBox:DisableButton(true)  -- Remove OK button
    searchBox:SetCallback("OnTextChanged", function(widget, event, text)
        self.searchText = text
        self:RefreshAddonList()
        -- Restore focus after refresh
        if widget.editbox then
            widget.editbox:SetFocus()
        end
    end)
    searchBox:SetCallback("OnEnterPressed", function(widget, event, text)
        self.searchText = text
        self:RefreshAddonList()
    end)
    container:AddChild(searchBox)
    
    -- Store references for filtering
    self.addonListContainer = container
    self.addonListSearchBox = searchBox
    self.addonListProfile = profile
    self.addonListIsReadOnly = isReadOnly
    
    -- Removed "Show only compatible" filter - not useful in practice
    
    -- Select All / Deselect All buttons
    local btnGroup = AceGUI:Create("SimpleGroup")
    btnGroup:SetFullWidth(true)
    btnGroup:SetLayout("Flow")
    
    local selectAllBtn = AceGUI:Create("Button")
    selectAllBtn:SetText("Select All")
    selectAllBtn:SetWidth(190)
    selectAllBtn:SetDisabled(isReadOnly)
    selectAllBtn:SetCallback("OnClick", function()
        if not profile then return end
        
        local allAddons = AddonProfiles.AddonManager:GetAllAddons()
        for name, info in pairs(allAddons) do
            if name ~= "AddonProfiles" then
                -- Only select visible addons (matching search)
                if not self.searchText or self.searchText == "" or
                   name:lower():find(self.searchText:lower(), 1, true) or
                   info.title:lower():find(self.searchText:lower(), 1, true) then
                    profile.addons[name] = true
                end
            end
        end
        
        self:RefreshAddonList()
        self:PopulateSettings() -- Update dep count
    end)
    btnGroup:AddChild(selectAllBtn)
    
    local deselectAllBtn = AceGUI:Create("Button")
    deselectAllBtn:SetText("Deselect All")
    deselectAllBtn:SetWidth(190)
    deselectAllBtn:SetDisabled(isReadOnly)
    deselectAllBtn:SetCallback("OnClick", function()
        if not profile then return end
        profile.addons = {}
        self:RefreshAddonList()
        self:PopulateSettings() -- Update dep count
    end)
    btnGroup:AddChild(deselectAllBtn)
    
    container:AddChild(btnGroup)
    
    -- Store button group reference
    self.addonListButtonGroup = btnGroup
    
    -- Spacing
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    container:AddChild(spacer)
    self.addonListSpacer = spacer
    
    -- Initial addon list population
    self:RefreshAddonList()
    
    self.MiddlePanel:AddChild(container)
end

function UI:RefreshAddonList()
    if not self.addonListContainer then
        return
    end
    
    local profile = self.addonListProfile
    local isReadOnly = self.addonListIsReadOnly
    
    if not profile then
        return
    end
    
    -- Remove existing scroll frame if present
    if self.addonListScroll then
        self.addonListContainer:ReleaseChildren()
        
        -- Re-add search box, buttons, and spacer
        self.addonListContainer:AddChild(self.addonListSearchBox)
        self.addonListContainer:AddChild(self.addonListButtonGroup)
        self.addonListContainer:AddChild(self.addonListSpacer)
    end
    
    -- Create new scroll frame
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetLayout("List")
    self.addonListScroll = scroll
    
    -- Get all addons
    local allAddons = AddonProfiles.AddonManager:GetAllAddons()
    
    -- Calculate which addons are required by dependencies
    local requiredByDeps = {}
    if profile.autoDeps then
        for addonName, selected in pairs(profile.addons) do
            if selected then
                local deps = AddonProfiles.AddonManager:GetAddonDependencies(addonName)
                for _, depName in ipairs(deps) do
                    requiredByDeps[depName] = true
                end
            end
        end
    end
    
    -- Sort addon names
    local addonNames = {}
    for name in pairs(allAddons) do
        table.insert(addonNames, name)
    end
    table.sort(addonNames)
    
    local displayedCount = 0
    
    for _, name in ipairs(addonNames) do
        local info = allAddons[name]
        
        -- Skip AddonProfiles itself
        if name ~= "AddonProfiles" then
            -- Apply search filter
            local showAddon = true
            if self.searchText and self.searchText ~= "" then
                local searchLower = self.searchText:lower()
                if not (name:lower():find(searchLower, 1, true) or
                       info.title:lower():find(searchLower, 1, true)) then
                    showAddon = false
                end
            end
            
            if showAddon then
                displayedCount = displayedCount + 1
                
                local checkbox = AceGUI:Create("CheckBox")
                
                -- Build label
                local label = info.title
                if #info.dependencies > 0 then
                    label = label .. " (deps: " .. table.concat(info.dependencies, ", ") .. ")"
                end
                
                checkbox:SetLabel(label)
                checkbox:SetFullWidth(true)
                checkbox:SetValue(profile.addons[name] == true)
                
                -- Disable if read-only or required by another addon's dependencies
                if isReadOnly then
                    checkbox:SetDisabled(true)
                elseif requiredByDeps[name] and not profile.addons[name] then
                    checkbox:SetDisabled(true)
                    checkbox:SetValue(true) -- Show as checked but disabled
                end
                
                if not isReadOnly then
                    checkbox:SetCallback("OnValueChanged", function(widget, event, value)
                        profile.addons[name] = value or nil
                        -- Only update settings panel, not entire addon list (prevents scroll jump)
                        self:PopulateSettings() -- Update dep count
                    end)
                end
                
                scroll:AddChild(checkbox)
            end
        end
    end
    
    if displayedCount == 0 then
        local noAddons = AceGUI:Create("Label")
        noAddons:SetText("No addons match filter")
        noAddons:SetFullWidth(true)
        scroll:AddChild(noAddons)
    end
    
    self.addonListContainer:AddChild(scroll)
end

