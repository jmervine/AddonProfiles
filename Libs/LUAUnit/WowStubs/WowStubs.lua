require("Libs.LUAUnit.WowStubs.SavedVariables")

SlashCmdList = {}

wowAddOnsStub = {
  [1] = {
    _enabled = true, -- non-Bliz public state, using for testing.
    name     = "TestAddOn_One",
    title    = "Test AddOn Sub #1",
    notes    = "Test AddOn Sub #1 Note",
    loadable = 1,
    reason   = nil,
    security = "INSECURE" -- default for all non Bliz addons
  },
  [2] = {
    _enabled = false, -- non-Bliz public state, using for testing.
    name     = "TestAddOn_Two",
    title    = "Test AddOn Sub #2",
    notes    = "Test AddOn Sub #2 Note",
    loadable = 1,
    reason   = nil,
    security = "INSECURE" -- default for all non Bliz addons
  },
  [3] = {
    _enabled = false, -- non-Bliz public state, using for testing.
    name     = "TestAddOn_Three",
    title    = "Test AddOn Sub #3",
    notes    = "Test AddOn Sub #3 Note",
    loadable = nil,
    reason   = "MISSING",
    security = "INSECURE" -- default for all non Bliz addons
  }
}

wowAddOnTemplates = {
  ["Default"] = { "TestAddOn_One" },
  ["TestCharacter@Raiding"] = {
    "TestAddOn_One", "TestAddOn_One"
  }
}

-- WoW: Global functions
-- ref: https://wowwiki-archive.fandom.com/wiki/API_UnitName
function UnitName(_)
  return "TestCharacter"
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetAddOnInfo
function GetAddOnInfo(a)
  -- check to see if it's a number
  n = tonumber(a)
  if n == nil then -- NaN
    for _, addon in ipairs(wowAddOnsStub) do
      if addon.name == a then
        return addon.name, addon.title, addon.notes, addon.loadable, addon.reason, addon.security, nil
      end
    end
  end

  addon = wowAddOnsStub[n]
  if not addon then
    return nil, nil, nil, nil, nil, nil, nil
  end

  return addon.name, addon.title, addon.notes, addon.loadable, addon.reason, addon.security, nil
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetAddOnEnableState
function GetAddOnEnableState(_, a)
  for i, addon in pairs(wowAddOnsStub) do
    if (addon.name == a or i == a) and (addon._enabled or addon.loadable) then
      return 2
    end
  end

  return 0
end

-- ref: https://wowpedia.fandom.com/wiki/API_GetNumAddOns
function GetNumAddOns()
  if not wowAddOnsStub then
    return 0
  end

  len = 0
  for _ in pairs(wowAddOnsStub) do
    len = len + 1
  end

  return len
end

-- ref: https://wowpedia.fandom.com/wiki/API_EnableAddOn
function EnableAddOn(aname, _)
  for i, addon in pairs(wowAddOnsStub) do
    if addon.name == aname or i == aname then
      wowAddOnsStub[i]._enabled = true
      wowAddOnsStub[i].loadable = 1
    end
  end
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAddOn
function DisableAddOn(aname, _)
  for i, addon in pairs(wowAddOnsStub) do
    if addon.name == aname or i == aname then
      wowAddOnsStub[i]._enabled = false
      wowAddOnsStub[i].loadable = false
    end
  end
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAllAddOns
function DisableAllAddOns()
  for i, _ in pairs(wowAddOnsStub) do
    wowAddOnsStub[i]._enabled = false
  end
end

-- support ace
local Frame = {}
function Frame:RegisterEvent(...)
  return {}
end

function Frame:SetScript(...)
  return {}
end

function Frame:AddMessage(...)
  return {}
end

DEFAULT_CHAT_FRAME = Frame

function CreateFrame(...)
  return Frame
end
