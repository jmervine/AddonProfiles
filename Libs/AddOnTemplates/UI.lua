function AddOnTemplates:ReloadUI()
  local dia = "ADDON_TEMPLATES_RELOAD_UI"
  if not StaticPopupDialogs[dia] then
    self:buildReloadUI()
  end
  StaticPopup_Show(dia)
end

function AddOnTemplates:buildReloadUI()
  StaticPopupDialogs["ADDON_TEMPLATES_RELOAD_UI"] = {
    text = "Reload UI?",
    button1 = "Reload",
    button2 = "Cancel",
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

