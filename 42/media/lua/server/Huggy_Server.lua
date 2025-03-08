
-- Server Tables:

HuggyServer = {}
HuggyServer.busy = {}

-- Mod ID and players:

local modID = "Huggies"

-- Sending huggy Requests

HuggyServer.isReceiverBusyServer = function (playersArgs)
    if HuggyServer.busy[playersArgs.senderName] or HuggyServer.busy[playersArgs.receiverName] then
        sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), modID, 'onReceivedAnotherHuggyRequest', {})
        HuggyServer.busy[playersArgs.senderName] = true
    else
        HuggyServer.busy[playersArgs.senderName] = true
        HuggyServer.busy[playersArgs.receiverName] = true
        HuggyServer.sendHuggyRequest(playersArgs)
    end
end

HuggyServer.sendHuggyRequest = function (playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), modID, 'huggyRequestSent', playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.receiverID), modID, 'huggyRequestReceived', playersArgs)
end

-- Button NO

HuggyServer.onDeclinedHuggyRequestServer = function (playersArgs)
    HuggyServer.busy[playersArgs.receiverName] = false

    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), modID, 'onDeclinedHuggyRequestClient', {})
end

-- Button YES

HuggyServer.onAcceptedHuggyRequestServer = function (playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), modID, 'onAcceptedHuggyRequestSender', playersArgs)
    sendServerCommand(getPlayerByOnlineID(playersArgs.receiverID), modID, 'onAcceptHuggyRequestReceiver', playersArgs)
end

-- Button CANCEL

HuggyServer.onCanceledHuggyRequestServer = function (playersArgs)
    HuggyServer.busy[playersArgs.senderName] = false
    HuggyServer.busy[playersArgs.receiverName] = false

    sendServerCommand(getPlayerByOnlineID(playersArgs.receiverID), modID, 'onCanceledHuggyRequestClient', {})
end

-- Clear Busy

HuggyServer.clearBusyOnServer = function (args)
    HuggyServer.busy[args.playerName] = false
end

HuggyServer.clearBusyAfterHuggyActionServer = function (playersArgs)
    HuggyServer.busy[playersArgs.senderName] = false
    HuggyServer.busy[playersArgs.receiverName] = false

    sendServerCommand(getPlayerByOnlineID(playersArgs.senderID), modID, 'clearBusyAfterHuggyActionClient', {})
    sendServerCommand(getPlayerByOnlineID(playersArgs.receiverID), modID, 'clearBusyAfterHuggyActionClient', {})
end

-- Start command

HuggyServer.processCommand = function(module, command, player, args)
    if module == modID and HuggyServer[command] then
        HuggyServer[command](args, player)
    end
end

Events.OnClientCommand.Add(HuggyServer.processCommand)

return HuggyServer