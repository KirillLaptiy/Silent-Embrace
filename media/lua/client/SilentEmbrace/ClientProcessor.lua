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

        return
    end

    print(123);

    sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll,
        SilentEmbraceClient.EmbracePlayers)
end

SilentEmbraceClient.sendRequest = function(playerArgs)
    SilentEmbraceClient.EmbracePlayers = {
        senderID = playerArgs.senderID,
        receiverID = playerArgs.receiverID,
        senderName = playerArgs.senderName,
        receiverName = playerArgs.receiverName
    }

    SilentEmbraceClient.ModalDialogs.senderDialog()

    SilentEmbraceClient.isBusy = true

    Events.OnTick.Add(SilentEmbraceClient.playersInGameCheck)
end

SilentEmbraceClient.receiveRequest = function(playerArgs)
    SilentEmbraceClient.EmbracePlayers = {
        senderID = playerArgs.senderID,
        receiverID = playerArgs.receiverID,
        senderName = playerArgs.senderName,
        receiverName = playerArgs.receiverName
    }

    SilentEmbraceClient.ModalDialogs.receiverDialog()

    SilentEmbraceClient.isBusy = true

    Events.OnTick.Add(SilentEmbraceClient.playersInGameCheck)
end

SilentEmbraceClient.declineRequest = function(isBusy)
    print(isBusy)

    if (SilentEmbraceClient.dialog) then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    SilentEmbraceClient.ModalDialogs.declinedDialog()

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

Events.OnServerCommand.Add(function(module, command, args)
    if not module == SilentEmbrace.ModID then return end

    SilentEmbraceClient[command](args)
end)
