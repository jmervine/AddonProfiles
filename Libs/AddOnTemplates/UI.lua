-- This file is not loaded in testing, so by setting this true here, we make sure that we
-- can skip loading this file in tests.
AddOnTemplates.LibsUI = true

-- InitializeUI
function AddOnTemplates:InitializeUI()
  self:CreateOptionsFrame()
  self:CreateReloadUI()
end

-- ReloadUI
function AddOnTemplates:CreateReloadUI()
  StaticPopupDialogs["ADDON_TEMPLATES_RELOAD_UI"] = {
    text = "Reload UI?",
    button1 = "Reload",
    button2 = "Cancel",
    sound = "levelup2",
    OnAccept = function()
        ReloadUI()
    end,
    OnCancel = function()
      AddOnTemplates:Printf(" ")
      AddOnTemplates:Printf("Type '/reload' to activate AddOns.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3 -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }
end

function AddOnTemplates:ReloadUI()
  StaticPopup_Show("ADDON_TEMPLATES_RELOAD_UI")
end

-- OptionsUI
function AddOnTemplates:CreateOptionsFrame()
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
    table.insert(usageText, "Saved Templates:")
    table.insert(usageText, "")

    local store = AddOnTemplatesStore

    if store == nil or next(store) == nil then
      table.insert(usageText, "No saved templates.")
    else
      for tname, template in pairs(store) do
        table.insert(usageText, string.format("  '%s' with %d AddOns.", tname, table.maxn(template)))
      end
    end

    usage:SetText(table.concat(usageText, "\n"))

    self.OptionsFrame = frame
  end

  return self.OptionsFrame 
end

function AddOnTemplates:OpenOptions()
  InterfaceAddOnsList_Update()
  InterfaceOptionsFrame_OpenToCategory(self.ADDON_NAME)
end
