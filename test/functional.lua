local helpers = require('libs.helpers')

require('test.stubs.wow.globals')
require('init')

function label(s)
  print()
  print("> " .. s)
  print('--')
end

-- HELP
label('/at help')
SlashCmdList["at"]("help")

label('/at help save')
SlashCmdList["at"]("help", "save")

label('/at help remove')
SlashCmdList["at"]("help", "remove")

-- LOAD
label('/at load')
SlashCmdList["at"]("load")

label('/at load TestCharacter@Raiding')
SlashCmdList["at"]("load", "TestCharacter@Raiding")
-- ensure enablement
local enabled = {}
for i=1, GetNumAddOns(), 1 do
  local name, _, _, _, _, _, _ = GetAddOnInfo(i)
  local enabledState = GetAddOnEnableState(nil, name)
  if enabledState > 0 then
    table.insert(enabled, name)
  end
end
print("ENABLED: " .. table.concat(enabled, ","))

-- SAVE
label('/at save')
SlashCmdList["at"]("save")

label('/at save')
SlashCmdList["at"]("save", "New_Template")

-- SHOW
label('/at show')
SlashCmdList["at"]("show")

label('/at show Default')
SlashCmdList["at"]("show", "Default")

label('/at show New_Template')
SlashCmdList["at"]("show", "New_Template")

-- REMOVE
label('/at remove')
SlashCmdList["at"]("remove")

label('/at remove New_Template')
SlashCmdList["at"]("remove", "New_Template")

label('/at show')
SlashCmdList["at"]("show")
