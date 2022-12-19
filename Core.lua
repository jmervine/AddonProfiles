-- AddOnName: AddOnTemplates
AT = LibStub("AceAddon-3.0"):NewAddon(Helpers.ADDON_NAME, "AceConsole-3.0")
function AT:OnInitialize()
    Core.Initialize()
end

function AT:OnEnable()
    Core.Initialize()
end

-- function AT:OnDisable()
-- end

for _, c in ipairs(Cmds.commands) do
    AT:RegisterChatCommand(c, "AT:SlashCommandHandler")
end

function AT:SlashCommandHandler(input)
    if (not input) or (input == "") then
        Cmds.execCommand("help", "")
        return
    end

    local parts = Helpers.SplitString(input)
    local len = Helpers.TableLen(parts)

    if len == 0 then
        Cmds.execCommand("help", "")
        return
    end 

    local subcmd = parts[1]
    if len == 1 then
        value = "" 
    elseif len == 2 then
        value  = parts[2]
    elseif len > 2 then
        table.remove(parts, parts[1])
        value = table.concat(parts, " ")
    end

    Cmds.execCommand(subcmd, value)
end