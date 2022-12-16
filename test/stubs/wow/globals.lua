require('test.stubs.wow.SavedVariables')

SlashCmdList = {}

wowAddOnsStub = {
  [1] = {
    name     = "TestAddOn_One",
    title    = "Test AddOn Sub #1",
    notes    = "Test AddOn Sub #1 Note",
    loadable = true,
    reason   = nil,
    security = "SECURITY: Not sure what's the for and I'm not using it."
  },
  [2] = {
    name     = "TestAddOn_Two",
    title    = "Test AddOn Sub #2",
    notes    = "Test AddOn Sub #2 Note",
    loadable = true,
    reason   = nil,
    security = "SECURITY: Not sure what's the for and I'm not using it."
  }
}

wowAddOnsEnabled = { "TestAddOn_One" }
wowAddOnTemplates = {
  ["Default"] = { "TestAddOn_One" },
  ["TestCharacter@Raiding"] = {
    "TestAddOn_One", "TestAddOn_One"
  }
}

-- WoW: Global functions
-- ref: https://wowwiki-archive.fandom.com/wiki/API_UnitName
function UnitName()
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
  for _, aname in pairs(wowAddOnsEnabled) do
    if aname == a then
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
  table.insert(wowAddOnsEnabled, aname)
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAddOn
function DisableAddOn(aname, _)
  local t = {}
  for _, v in pairs(wowAddOnsEnabled) do
    if v == aname then
      table.insert(t, v)
    end
  end

  wowAddOnsEnabled = t
end

-- ref: https://wowpedia.fandom.com/wiki/API_DisableAllAddOns
function DisableAllAddOns()
  wowAddOnsEnabled = {}
end
