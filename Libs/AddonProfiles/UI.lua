-- This file is not loaded in testing, so by setting this true here, we make sure that we
-- can skip loading this file in tests.
AddonProfiles.LibsUI = true

-- InitializeUI
function AddonProfiles:InitializeUI()
  self:CreateOptionsFrame()
  self:CreateReloadUI()
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
