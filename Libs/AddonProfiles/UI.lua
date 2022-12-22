-- This file is not loaded in testing, so by setting this true here, we make sure that we
-- can skip loading this file in tests.
AddonProfiles.LibsUI = true

local AceGUI = LibStub("AceGUI-3.0")

-- InitializeUI
function AddonProfiles:InitializeUI()
  -- self:CreateOptionsFrame()
  self:CreateReloadUI()
end

-- HelpUI
function AddonProfiles:HelpUI()
  local name = "Help"

  -- frame
  local frame = AceGUI:Create("Frame")
  frame:SetLayout("List")
  frame:SetTitle(string.format("%s - %s", AddonProfiles.ADDON_NAME, name))
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
  frame:SetFullWidth()
  frame:SetFullHeight()

  local heading = AceGUI:Create("Label")
  heading:SetText("Usage")
  heading:SetFontObject("GameFontNormalLarge")
  frame:AddChild(heading)

  local usageText = {
    "",
    string.format("Usage: /%s [option] (aliases: '%s')", self.SlashCommands, table.concat(self.SlashAliases, "', '")),
    ""
  }

  for cmd, cfg in pairs(self.HelpMessages) do
    table.insert(usageText, string.format("  '%s %s': %s", cmd, cfg.opts, cfg.desc))
  end

  local text = table.concat(usageText, "\n")
  self:Print(text)

  local usage = AceGUI:Create("Label")
  usage:SetRelativeWidth(0.95)
  usage:SetHeight(500)
  usage:SetText(text)
  usage:SetFontObject("GameTooltipText")
  frame:AddChild(usage)
end

-- ImportUI
function AddonProfiles:ImportUI()
  local name = "Import"

  -- frame
  local frame = AceGUI:Create("Frame")
  frame:SetLayout("Fill")
  frame:SetTitle(string.format("%s - %s", AddonProfiles.ADDON_NAME, name))
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

  -- editbox
  local editbox = AceGUI:Create("MultiLineEditBox")
  editbox:SetFullWidth()
  editbox:SetFullHeight()
  editbox:SetLabel(string.format("%s:", name))
  editbox:SetNumLines(20)
  editbox:SetMaxLetters(0)
  editbox:DisableButton(false)
  editbox:SetDisabled(false)
  editbox:SetFocus()

  editbox:SetCallback("OnEnterPressed", function(_)
    local ok, msg = self:ImportProfiles(editbox:GetText())
    if not ok then
      frame:SetStatusText(msg)
      return
    end

    frame:SetStatusText("Import successful.")
    local usageText = {}
    table.insert(usageText, "Saved Profiles:")
    table.insert(usageText, "")

    local store = AddonProfilesStore

    if store == nil or next(store) == nil then
      table.insert(usageText, "No saved profiles.")
    else
      for tname, profile in pairs(store) do
        table.insert(usageText, string.format("  '%s' with %d Addons.", tname, table.maxn(profile)))
      end
    end

    editbox:SetText(table.concat(usageText, "\n"))
  end)

  frame:AddChild(editbox)
end

-- ExportUI
function AddonProfiles:ExportUI()
  local name = "Export"

  local exported = ""
  local ok, str = self:ExportProfiles()
  if not ok then
    statusText = str
  else
    exported = str
  end

  -- frame
  local frame = AceGUI:Create("Frame")
  frame:SetLayout("Fill")
  frame:SetTitle(string.format("%s - %s", AddonProfiles.ADDON_NAME, name))
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

  -- editbox
  local editbox = AceGUI:Create("MultiLineEditBox")
  editbox:SetFullWidth()
  editbox:SetFullHeight()
  editbox:SetLabel(string.format("%s:", name))
  editbox:SetNumLines(20)
  editbox:SetMaxLetters(0)
  editbox:DisableButton(false)
  editbox:SetDisabled(false)
  editbox:SetFocus()

  local ok, exported = self:ExportProfiles()

  if not ok then
    editbox:SetDisabled(true)
    editbox:SetStatusText(exported)
  else
    editbox:SetText(exported)
    editbox:HighlightText(0, string.len(exported)) 
  end

  -- hack to make this not editable 
  --  TODO: find a better solution
  editbox:SetCallback("OnTextChanged", function(_) 
    if ok then
      editbox:SetText(exported) 
      editbox:HighlightText(0, string.len(exported))
    end
  end)

  frame:AddChild(editbox)
end

-- ReloadUI
function AddonProfiles:CreateReloadUI()
  StaticPopupDialogs["ADDON_PROFILES_RELOAD_UI"] = {
    text = "Reload UI?",
    button1 = "Reload",
    button2 = "Cancel",
    sound = "levelup2",
    OnAccept = function()
        ReloadUI()
    end,
    OnCancel = function()
      AddonProfiles:Printf(" ")
      AddonProfiles:Printf("Type '/reload' to activate Addons.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }
end

function AddonProfiles:ReloadUI()
  StaticPopup_Show("ADDON_PROFILES_RELOAD_UI")
end

-- OptionsUI
-- function AddonProfiles:CreateOptionsFrame()
--   if not self.OptionsFrame then
--     local frame = CreateFrame("Frame")
--     frame.name = self.ADDON_NAME
--     InterfaceOptions_AddCategory(frame)
-- 
--     local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
--     scroll:SetPoint("TOPLEFT", 3, -4)
--     scroll:SetPoint("BOTTOMRIGHT", -27, 4)
-- 
--     local panel = CreateFrame("Frame")
--     scroll:SetScrollChild(panel)
--     panel:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth()-18)
--     panel:SetHeight(1)
-- 
--     local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
--     title:SetPoint("TOPLEFT", 10, -10)
--     title:SetText(self.ADDON_NAME)
-- 
--     local usage = panel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
--     usage:SetJustifyH("LEFT")
--     usage:SetJustifyV("TOP")
--     usage:SetPoint("TOPLEFT", 10, -40)
-- 
--     local usageText = {
--       string.format("Usage: /%s [option] (aliases: '%s')", self.SlashCommands, table.concat(self.SlashAliases, "', '")),
--       "" -- for two newlines
--     }
-- 
--     for cmd, cfg in pairs(self.HelpMessages) do
--       table.insert(usageText, string.format("  '%s %s': %s", cmd, cfg.opts, cfg.desc))
--     end
-- 
--     table.insert(usageText, "")
--     table.insert(usageText, "")
--     table.insert(usageText, "Saved Profiles:")
--     table.insert(usageText, "")
-- 
--     local store = AddonProfilesStore
-- 
--     if store == nil or next(store) == nil then
--       table.insert(usageText, "No saved profiles.")
--     else
--       for tname, profile in pairs(store) do
--         table.insert(usageText, string.format("  '%s' with %d Addons.", tname, table.maxn(profile)))
--       end
--     end
-- 
--     usage:SetText(table.concat(usageText, "\n"))
-- 
--     self.OptionsFrame = frame
--   end
-- 
--   return self.OptionsFrame
-- end
-- 
-- function AddonProfiles:OpenOptions()
--   InterfaceOptionsFrame_OpenToCategory(self.ADDON_NAME)
-- end
-- 