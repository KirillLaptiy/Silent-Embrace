--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

local clearHuggyBusy = {}

clearHuggyBusy.awaitClientCommandAbility = function()
    clearHuggyBusy.waitTicks = (clearHuggyBusy.waitTicks and (clearHuggyBusy.waitTicks - 1)) or 5

    if clearHuggyBusy.waitTicks == 5 then
        Events.OnTick.Add(clearHuggyBusy.awaitClientCommandAbility)
    elseif clearHuggyBusy.waitTicks == 0 then
        clearHuggyBusy.waitTicks = nil
        Events.OnTick.Remove(clearHuggyBusy.awaitClientCommandAbility)

        for playerIndex = 0, getNumActivePlayers() - 1 do
            local player = getSpecificPlayer(playerIndex)

            if player then
                sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearBusy,
                    { playerName = player:getDisplayName() })
            end
        end
    end
end

Events.OnCreatePlayer.Add(clearHuggyBusy.awaitClientCommandAbility)

return clearHuggyBusy
