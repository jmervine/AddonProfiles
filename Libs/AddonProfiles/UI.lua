-- This file is not loaded in testing, so by setting this true here, we make sure that we
-- can skip loading this file in tests.
AddonProfiles.LibsUI = true

local AceGUI = LibStub("AceGUI-3.0")

-- InitializeUI
function AddonProfiles:InitializeUI()
  self:CreateOptionsFrame()
  self:CreateReloadUI()
end

-- ImportUI
function AddonProfiles:ImportUI()
  local frame = AceGUI:Create("Frame")
  frame:SetLayout("Flow")
  frame:SetTitle(string.format("%s - Import", AddonProfiles.ADDON_NAME))
  frame:SetStatusText("Paste in import string.")
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

  local editbox = AceGUI:Create("EditBox")
  editbox:SetWidth(600)
  editbox:SetHeight(600)
  editbox:SetFocus()
  editbox:SetMultiLine()
  frame:AddChild(editbox)

  local import = AceGUI:Create("Button")
  import:SetText("Import")
  import:SetWidth(100)
  import:RegisterForClicks("AnyUp", "AnyDown")
  import:SetScript("OnClick", function (_, button, down)
    if not down and button == "LeftButton" then
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
    end
  end)
  frame:AddChild(import)

  local cancel = AceGUI:Create("Button")
  cancel:SetText("Cancel")
  cancel:SetWidth(100)
  cancel:RegisterForClicks("AnyUp", "AnyDown")
  cancel:SetScript("OnClick", function (_, button, down)
    if not down and button == "LeftButton" then
      AceGUI:Release(frame)
    end
  end)
  frame:AddChild(cancel)
end

-- ExportUI
function AddonProfiles:ExportUI()
  local statusText = "Copy and save export string."
  local exported = ""

  local ok, str = self:Export()
  if not ok then
    statusText = str
  else
    exported = str
  end

  local frame = AceGUI:Create("Frame")
  frame:SetLayout("Flow")
  frame:SetTitle(string.format("%s - Export", AddonProfiles.ADDON_NAME))
  frame:SetStatusText(statsText)
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

  local editbox = AceGUI:Create("EditBox")
  editbox:SetWidth(600)
  editbox:SetHeight(600)
  editbox:SetFocus()
  editbox:SetMultiLine()
  editbox:SetText(exported)
  frame:AddChild(editbox)

  local cancel = AceGUI:Create("Button")
  cancel:SetText("Close")
  cancel:SetWidth(100)
  cancel:RegisterForClicks("AnyUp", "AnyDown")
  cancel:SetScript("OnClick", function (_, button, down)
    if not down and button == "LeftButton" then
      AceGUI:Release(frame)
    end
  end)
  frame:AddChild(cancel)
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
function AddonProfiles:CreateOptionsFrame()
  if not self.OptionsFrame then
    local frame = CreateFrame("Frame")
    frame.name = self.ADDON_NAME
    InterfaceOptions_AddCategory(frame)

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 3, -4)
    scroll:SetPoint("BOTTOMRIGHT", -27, 4)

    local panel = CreateFrame("Frame")
    scroll:SetScrollChild(panel)
    panel:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth()-18)
    panel:SetHeight(1)

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(self.ADDON_NAME)

    local usage = panel:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    usage:SetJustifyH("LEFT")
    usage:SetJustifyV("TOP")
    usage:SetPoint("TOPLEFT", 10, -40)

    local usageText = {
      string.format("Usage: /%s [option] (aliases: '%s')", self.SlashCommands, table.concat(self.SlashAliases, "', '")),
      "" -- for two newlines
    }

    for cmd, cfg in pairs(self.HelpMessages) do
      table.insert(usageText, string.format("  '%s %s': %s", cmd, cfg.opts, cfg.desc))
    end

    table.insert(usageText, "")
    table.insert(usageText, "")
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

    usage:SetText(table.concat(usageText, "\n"))

    self.OptionsFrame = frame
  end

  return self.OptionsFrame
end

function AddonProfiles:OpenOptions()
  InterfaceAddonsList_Update()
  InterfaceOptionsFrame_OpenToCategory(self.ADDON_NAME)
end
