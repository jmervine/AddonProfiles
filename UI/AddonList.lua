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
    
    -- Search box
    local searchBox = AceGUI:Create("EditBox")
    searchBox:SetLabel("Search")
    searchBox:SetFullWidth(true)
    searchBox:SetText(self.searchText)
    searchBox:SetCallback("OnTextChanged", function(widget, event, text)
        self.searchText = text
        self:PopulateAddonList()
    end)
    container:AddChild(searchBox)
    
    -- Filter checkbox
    local filterCheck = AceGUI:Create("CheckBox")
    filterCheck:SetLabel("Show only compatible")
    filterCheck:SetValue(self.showOnlyCompatible)
    filterCheck:SetFullWidth(true)
    filterCheck:SetCallback("OnValueChanged", function(widget, event, value)
        self.showOnlyCompatible = value
        self:PopulateAddonList()
    end)
    container:AddChild(filterCheck)
    
    -- Select All / Deselect All buttons
    local btnGroup = AceGUI:Create("SimpleGroup")
    btnGroup:SetFullWidth(true)
    btnGroup:SetLayout("Flow")
    
    local selectAllBtn = AceGUI:Create("Button")
    selectAllBtn:SetText("Select All")
    selectAllBtn:SetWidth(190)
    selectAllBtn:SetCallback("OnClick", function()
        if not profile then return end
        
        local allAddons = AddonProfiles.AddonManager:GetAllAddons()
        for name, info in pairs(allAddons) do
            if name ~= "AddonProfiles" and (not self.showOnlyCompatible or info.loadable) then
                if not self.searchText or self.searchText == "" or
                   name:lower():find(self.searchText:lower(), 1, true) or
                   info.title:lower():find(self.searchText:lower(), 1, true) then
                    profile.addons[name] = true
                end
            end
        end
        
        self:PopulateAddonList()
        self:PopulateSettings() -- Update dep count
    end)
    btnGroup:AddChild(selectAllBtn)
    
    local deselectAllBtn = AceGUI:Create("Button")
    deselectAllBtn:SetText("Deselect All")
    deselectAllBtn:SetWidth(190)
    deselectAllBtn:SetCallback("OnClick", function()
        if not profile then return end
        profile.addons = {}
        self:PopulateAddonList()
        self:PopulateSettings() -- Update dep count
    end)
    btnGroup:AddChild(deselectAllBtn)
    
    container:AddChild(btnGroup)
    
    -- Spacing
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    container:AddChild(spacer)
    
    -- Addon list (scrollable)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetLayout("List")
    
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
            -- Apply filters
            local showAddon = true
            
            -- Search filter
            if self.searchText and self.searchText ~= "" then
                local searchLower = self.searchText:lower()
                if not (name:lower():find(searchLower, 1, true) or
                       info.title:lower():find(searchLower, 1, true)) then
                    showAddon = false
                end
            end
            
            -- Compatible filter
            if self.showOnlyCompatible and not info.loadable then
                showAddon = false
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
                
                -- Disable if required by another addon's dependencies
                if requiredByDeps[name] and not profile.addons[name] then
                    checkbox:SetDisabled(true)
                    checkbox:SetValue(true) -- Show as checked but disabled
                end
                
                checkbox:SetCallback("OnValueChanged", function(widget, event, value)
                    profile.addons[name] = value or nil
                    self:PopulateAddonList() -- Refresh to update dependency graying
                    self:PopulateSettings() -- Update dep count
                end)
                
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
    
    container:AddChild(scroll)
    self.MiddlePanel:AddChild(container)
end

