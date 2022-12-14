-- Slash Commands
SlashCommands = { "addontemplates", "ats" }

function LoadSlashCommands()
  for _, c in pairs(SlashCommands) do
    SlashCmdList[c] = AddOnTemplatesCmd
  end
end

function AddOnTemplatesCmd(action, value)
  if not action then
    showTemplates()
  else
    if action == "help" then
      showHelp(value)
    --elseif action == "save" then
      --saveTemplate(value)
    elseif action == "load" then
      LoadAddOnsTemplate(value)
    elseif action == "show" then
      showTemplate(value)
    else
      showTemplate(action)
    end
  end
end

function showTemplates()
  print("AddOn Templates:", tableKeys(AddOnTemplates, ", "))
end

function showTemplate(template)
  local templates = AddOnTemplates[template]
  print(template, table.concat(templates, ", "))
end

function showHelp(help)
  help = {}
  help["templates"] = "/templates :: Display the names of all saved templates."
  help["template"] = "/template TEMPLATE_NAME :: Display the AddOns included by this template."

  if not help then
  end
end
