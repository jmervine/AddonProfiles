local Core = {} -- Class

-- ADDON_NAME: AddOnTemplates
Core.ADDON_NAME       = "AddOnTemplates"
Core.TEMPLATE_DEFAULT = "Default"

-- Current Character
Core.Character = UnitName("player")

-- Store AddOnTemplates once loaded.
Core.Templates = {}

-- Other useful module globals
Core.CurrentStateEnablement = 0
Core.CurrentState = nil

function Core:SetAddOnState()
  local state = {}
  for i=1, GetNumAddOns(), 1 do
    local name, title, notes, loadable, reason, security, _ = GetAddOnInfo(i)
    local enabledState = GetAddOnEnabledState(name)

    if Core.CurrentStateEnablement < enabledState then
      Core.CurrentStateEnablement = enabledState
    end

    state[name] = {}
    state[name].Index     = i
    state[name].Name      = name
    state[name].Title     = title
    state[name].Notes     = notes
    state[name].Loadable  = loadable
    state[name].Reason    = reason
    state[name].Security  = security
    state[name].Installed = true
    state[name].Enabled   = enabledState
  end

  Core.CurrentState = state
end

function LoadAddOnTemplates()
  Core.Templates = AddOnTemplates

  -- If there isn't an existing saved template, create one from the existing
  -- state.
  if not Templates then
    Core.Templates = {}

    local template = newTemplate()

    -- If all addons are disabled, return an empty template.
    if Core.CurrentStateEnabledment == 0 then
      Core.Templates[Core.TEMPLATE_DEFAULT] = {}
      return
    end

    local name

    -- If there are character level addon toggles, then the default template
    -- should include the characters name.
    if Core.CurrentStateEnablement == 1 then
      name = serverDefaultName()
    else
      name = Core.TEMPLATE_DEFAULT
    end

    Core.Templates[name] = template

    return
  end

  -- This assumes we've found some existing templates. We're going to loop through
  -- them and ensure that all templates are marked "Installed" correctly.
  local state = AddOnState()
  for tname, template in pairs(Core.Templates) do
    for aname, addon in pairs(template) do
      if not state[aname] then
        Core.Templates[tname][aname].Installed = false
      end
    end
  end
end

function LoadAddOnsTemplate(tname)
  if not tname then
    tname = Core.TEMPLATE_DEFAULT
    if not Core.Templates[tname] then
      tname = serverDefaultName()
    end
  end

  if not Core.Templates[tname] then
    err(tname .. " template, does not exist.")
    return
  end

  DisableAllAddOns()

  for _, addon in Core.Templates[tname] do
    if not addon.Installed then
      warn(addon.Name .. " from " .. tname .. " template, is no longer installed.")
    elseif not addon.Loadable then
      warn(addon.Name .. " from " .. tname .. " template, not loadable (Reason: " .. addon.Reason .. ").")
    else
      EnabledAddOn(addon.Name)
    end
  end
end

function SaveAddOnsTemplate(tname)
  if not tname then
    if Core.CurrentState == 1 then
      tname = Core.Character .. "@Default"
    else
      tname = "Default"
    end
  end
end

local function newTemplate()
  local template = {}

  local state = AddOnState()
  for _, addon in pairs(state) do
    if addon.Enabled > 0 then
      template[addon.Name] = addon
    end
  end

  return template
end

-- Locals
local function warn(str)
  msg("WARNING", str)
end

local function err(str)
  msg("ERROR", str)
end

local function msg(t, str)
  print(Core.ADDON_NAME .. ": [" .. t .. "] " .. str)
end

local function serverDefaultName()
  return Core.Character .. "@" .. Core.TEMPLATE_DEFAULT
end

return Core
