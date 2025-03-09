-- Sending huggy Requests

SilentEmbraceServer.sendRequest = function(playersArgs)
    local sender = getPlayerByOnlineID(playersArgs.senderID)
    local receiver = getPlayerByOnlineID(playersArgs.receiverID)

    local senderName = sender:getDisplayName()
    local receiverName = receiver:getDisplayName()

    if SilentEmbraceServer.BusyPlayers[receiverName] then
        SilentEmbraceServer.BusyPlayers[senderName] = true

        sendServerCommand(
            sender,
            SilentEmbrace.ModID,
            SilentEmbrace.Commands.cancelRequest,
            { isBusy = true }
        )
    else
        SilentEmbraceServer.BusyPlayers[senderName] = true
        SilentEmbraceServer.BusyPlayers[receiverName] = true

        sendServerCommand(
            sender,
            SilentEmbrace.ModID,
            SilentEmbrace.Commands.sendRequest,
            playersArgs
        )
        sendServerCommand(
            receiver,
            SilentEmbrace.ModID,
            SilentEmbrace.Commands.receiveRequest,
            playersArgs
        )
    end
end

-- Button NO

SilentEmbraceServer.declineRequest = function(playersArgs)
    SilentEmbraceServer.BusyPlayers[playersArgs.receiverName] = false

    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), SilentEmbrace.ModID,
        SilentEmbrace.Commands.declineRequest, {})
end

-- Button YES

SilentEmbraceServer.acceptRequest = function(playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), SilentEmbrace.ModID,
        SilentEmbrace.Commands.startHugSender, playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.receiverID), SilentEmbrace.ModID,
        SilentEmbrace.Commands.startHugReceiver, playersArgs)
end

-- Button CANCEL

SilentEmbraceServer.cancelRequest = function(playersArgs)
    local receiver = getPlayerByOnlineID(playersArgs.receiverID)

    SilentEmbraceServer.BusyPlayers[playersArgs.senderName] = false
    SilentEmbraceServer.BusyPlayers[playersArgs.receiverName] = false

    sendServerCommand(receiver, SilentEmbrace.ModID,
        SilentEmbrace.Commands.cancelRequest, {})
end

-- Clear Busy

SilentEmbraceServer.clearBusy = function(playerName)
    SilentEmbraceServer.BusyPlayers[playerName] = false
end

SilentEmbraceServer.clearAll = function(playersArgs)
    local sender = getPlayerByOnlineID(playersArgs.senderID)
    local receiver = getPlayerByOnlineID(playersArgs.receiverID)

    SilentEmbraceServer.BusyPlayers[playersArgs.senderName] = false
    SilentEmbraceServer.BusyPlayers[playersArgs.receiverName] = false

    sendServerCommand(sender, SilentEmbrace.ModID,
        SilentEmbrace.Commands.clearBusy, {})

    sendServerCommand(receiver, SilentEmbrace.ModID,
        SilentEmbrace.Commands.clearBusy, {})
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == SilentEmbrace.ModID and SilentEmbraceServer[command] then
        SilentEmbraceServer[command](args, player)
    end
end)
