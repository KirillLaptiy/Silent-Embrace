
HuggingPlayersArgs = {}
local modID = "Huggies"
local modal

-- Sender modal

HuggyClient.huggyRequestSent = function ()
    modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - 175, getCore():getScreenHeight() / 2 - 75, 350, 150, getText("IGUI_HuggyUI_SentHuggyRequest to:" .. " " .. HuggingPlayersArgs.receiverName), nil, true, HuggyClient.onAnswerHuggyRequest);
    modal:initialise()
    modal:addToUIManager()
    modal:removeChild(modal.ok);
    modal.ok = nil;
    modal.moveWithMouse = true; 

    local btnWid = 100
    local btnHgt = math.max(25, getTextManager():getFontHeight(UIFont.Small) + 3 * 2)
    local padBottom = 10
    modal.cancel = ISButton:new((modal:getWidth() / 2) - btnWid / 2, modal:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), modal, ISModalDialog.onClick);
    modal.cancel.internal = "CANCEL";
    modal.cancel.anchorTop = false;
    modal.cancel.anchorBottom = true;
    modal.cancel:initialise();
    modal.cancel:instantiate();
    modal.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    modal:addChild(modal.cancel);

    HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = true
    Events.OnTick.Add(HuggyClient.playersInGameCheck)
end

-- Receiver modal

HuggyClient.huggyRequestReceived = function ()
    modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - 175,getCore():getScreenHeight() / 2 - 75, 350, 150, getText("IGUI_HuggyUI_HuggyRequest by:" .. " " .. HuggingPlayersArgs.senderName), true, nil, HuggyClient.onAnswerHuggyRequest);
    modal:initialise()
    modal:addToUIManager()
    modal.moveWithMouse = true;

    HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = true
    Events.OnTick.Add(HuggyClient.playersInGameCheck)
end

-- Send buttons (player 1)

function HuggyClient:onAnswerHuggyRequest (button)

    if button.internal == "NO" then
        sendClientCommand(modID, "onDeclinedHuggyRequestServer", HuggingPlayersArgs)
        HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = false
        Events.OnTick.Remove(HuggyClient.playersInGameCheck)

    elseif button.internal == "YES" then
        sendClientCommand(modID, "onAcceptedHuggyRequestServer", HuggingPlayersArgs)

    elseif button.internal == "CANCEL" then -- CANCEL BUTTON
        sendClientCommand(modID, "onCanceledHuggyRequestServer", HuggingPlayersArgs)
        HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = false
        Events.OnTick.Remove(HuggyClient.playersInGameCheck)

    elseif button.internal == "OK" then -- CANCEL BUTTON
        sendClientCommand(modID, "clearBusyOnServer", {playerName = HuggingPlayersArgs.localPlayerName})
        HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = false
    end
end

-- Receive buttons response (player 2)

HuggyClient.onDeclinedHuggyRequestClient = function ()
    modal:removeFromUIManager()
    modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - 175,getCore():getScreenHeight() / 2 - 75, 350, 150, getText("IGUI_HuggyUI_NowannaHuggy"), nil, true, HuggyClient.onAnswerHuggyRequest);
    modal:initialise()
    modal:addToUIManager()
    Events.OnTick.Remove(HuggyClient.playersInGameCheck)
end

HuggyClient.onAcceptedHuggyRequestSender = function ()
    modal:removeFromUIManager()
end

HuggyClient.onCanceledHuggyRequestClient = function ()
    modal:removeFromUIManager()
    HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = false
    Events.OnTick.Remove(HuggyClient.playersInGameCheck)
end

-- Receiving a message when trying to send a Huggy request to a player, who currently has a Huggy request

HuggyClient.onReceivedAnotherHuggyRequest = function ()
    modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - 175,getCore():getScreenHeight() / 2 - 75, 350, 150, getText("IGUI_HuggyUI_ThisPlayerReceivedAnotherHuggyRequest"), nil, true, HuggyClient.onAnswerHuggyRequest);
    modal:initialise()
    modal:addToUIManager()
    HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = true
end

-- Clearing client huggy busy

HuggyClient.clearBusyAfterHuggyActionClient = function ()
    if modal then
        modal:removeFromUIManager()
    end

	ISTimedActionQueue.clear(getPlayer())
	HuggyClient.busy[HuggingPlayersArgs.localPlayerName] = false
    Events.OnTick.Remove(HuggyClient.playersInGameCheck)
end

-- Checking players are still in game and standing close each other

HuggyClient.playersInGameCheck = function ()
    local sender = getPlayerByOnlineID(HuggingPlayersArgs.senderID)
    local receiver = getPlayerByOnlineID(HuggingPlayersArgs.receiverID)

    if sender and receiver then
        local distanceX = math.abs(sender:getX() - receiver:getX())
        local distanceY = math.abs(sender:getY() - receiver:getY())

        if distanceX > 3 or distanceY > 3 then
            sendClientCommand(modID, "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
        end

        return
    end

    sendClientCommand(modID, "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
end

-- Start command

HuggyClient.processServerCommand = function (module, command, args)
    if not (module == modID and HuggyClient[command]) then return end

    if command == 'huggyRequestSent' or command == 'huggyRequestReceived' then
        HuggingPlayersArgs = args
        HuggingPlayersArgs.localPlayerName = getPlayer():getDisplayName()
    end

    HuggyClient[command](args)
end

Events.OnServerCommand.Add(HuggyClient.processServerCommand)

return HuggyClient


