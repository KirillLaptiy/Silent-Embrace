--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

local busyWalkTo = ISWalkToTimedAction.isValid

function ISWalkToTimedAction:isValid()
    if SilentEmbraceClient.isBusy then
        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll,
            SilentEmbraceClient.EmbracePlayers)
        return false
    end

    return busyWalkTo(self)
end

local busySitOnGround = ISWorldObjectContextMenu.onSitOnGround

ISWorldObjectContextMenu.onSitOnGround = function(player)
    if SilentEmbraceClient.isBusy then
        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll,
            SilentEmbraceClient.EmbracePlayers)
        return
    end

    return busySitOnGround(player)
end
