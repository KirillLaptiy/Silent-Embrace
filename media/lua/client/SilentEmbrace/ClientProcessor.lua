--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

SilentEmbraceClient.playersInGameCheck = function()
    local sender = getPlayerByOnlineID(SilentEmbraceClient.EmbracePlayers.senderID)
    local receiver = getPlayerByOnlineID(SilentEmbraceClient.EmbracePlayers.receiverID)

    if sender and receiver then
        local distanceX = math.abs(sender:getX() - receiver:getX())
        local distanceY = math.abs(sender:getY() - receiver:getY())

        if distanceX > 3 or distanceY > 3 then
            sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll,
                SilentEmbraceClient.EmbracePlayers)
        end

        -- When request accepted starting check for stop both players close each other
        if SilentEmbraceClient.isWalkingToStartEmbrace then
            local player = getPlayer()

            local treeSquare = player:getCurrentSquare():Has(IsoObjectType.tree)

            if treeSquare == false then
                player:setGhostMode(true)
            else
                player:setGhostMode(false)
            end

            if player:pressedMovement(false) or player:pressedCancelAction() or player:pressedAim() then
                sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearEmbrace,
                    SilentEmbraceClient.EmbracePlayers)
                return
            end

            if distanceX <= 0.4 and distanceY <= 0.4 then
                ISTimedActionQueue.clear(player)

                -- to optimize
                ISTimedActionQueue.add(ISHuggyTimedAction:new(player,
                    SilentEmbraceClient.EmbracePlayers.huggingCharacter))

                SilentEmbraceClient.isWalkingToStartEmbrace = false
            end
        end
    else
        -- if one of players left the game clearing server busy
        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll,
            SilentEmbraceClient.EmbracePlayers)
    end
end

local onRequestSended = function(playerArgs, dialog)
    SilentEmbraceClient.EmbracePlayers = {
        senderID = playerArgs.senderID,
        receiverID = playerArgs.receiverID,
        senderName = playerArgs.senderName,
        receiverName = playerArgs.receiverName
    }

    dialog()

    SilentEmbraceClient.isBusy = true

    Events.OnTick.Add(SilentEmbraceClient.playersInGameCheck)
end

SilentEmbraceClient.sendRequest = function(playerArgs)
    onRequestSended(playerArgs, SilentEmbraceClient.ModalDialogs.senderDialog)
end

SilentEmbraceClient.receiveRequest = function(playerArgs)
    onRequestSended(playerArgs, SilentEmbraceClient.ModalDialogs.receiverDialog)
end

SilentEmbraceClient.declineRequest = function(args)
    if (SilentEmbraceClient.dialog) then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    if (args.isBusy) then SilentEmbraceClient.isBusy = true end

    SilentEmbraceClient.ModalDialogs.declinedDialog(args.isBusy)

    Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
end

SilentEmbraceClient.cancelRequest = function()
    if (SilentEmbraceClient.dialog) then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    SilentEmbraceClient.isBusy = false

    Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
end

SilentEmbraceClient.clearBusy = function()
    SilentEmbraceClient.isBusy = false
    Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
end

-- Huggy action
SilentEmbraceClient.clearAll = function()
    getPlayer():setGhostMode(false)
end

-- Walking to huggy action and starting it
local startHugging = function(secondPlayer)
    local player = getPlayer()

    ISTimedActionQueue.clear(player)
    ISTimedActionQueue.add(
        ISWalkToHuggy:new(
            player,
            secondPlayer:getSquare()
        )
    )

    SilentEmbraceClient.EmbracePlayers.huggingCharacter = secondPlayer
    SilentEmbraceClient.isWalkingToStartEmbrace = true
end

-- (Need edit to optimization)
SilentEmbraceClient.startHugSender = function(playerArgs)
    if (SilentEmbraceClient.dialog) then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    local secondPlayer = getPlayerByOnlineID(playerArgs.receiverID)

    startHugging(secondPlayer)
end

SilentEmbraceClient.startHugReceiver = function(playerArgs)
    local secondPlayer = getPlayerByOnlineID(playerArgs.senderID)

    startHugging(secondPlayer)
end

SilentEmbraceClient.clearEmbrace = function()
    if SilentEmbraceClient.dialog then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    ISTimedActionQueue.clear(getPlayer())
    SilentEmbraceClient.isBusy = false
    Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
end

-- Processor
Events.OnServerCommand.Add(function(module, command, args)
    if not module == SilentEmbrace.ModID then return end

    SilentEmbraceClient[command](args)
end)
