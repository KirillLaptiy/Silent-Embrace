
local busyWalkTo = ISWalkToTimedAction.isValid

function ISWalkToTimedAction:isValid()
    if HuggyClient.busy[self.character:getDisplayName()] then
        sendClientCommand("Huggies", "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
        return false
    end

    return busyWalkTo(self)
end

local busySitOnGround = ISWorldObjectContextMenu.onSitOnGround

ISWorldObjectContextMenu.onSitOnGround = function(player)
    if HuggyClient.busy[getSpecificPlayer(player):getDisplayName()] then
        sendClientCommand("Huggies", "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
        return
    end

    return busySitOnGround(player)
end