-- Client Tables:

HuggyClient = {}
HuggyClient.busy = {}

local modID = "Huggies"

local createHuggyContext = ISWorldObjectContextMenu.createMenu

---@diagnostic disable-next-line: duplicate-set-field
ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = createHuggyContext(player, worldobjects, x, y, test)

    local playerObj = getSpecificPlayer(player)

    if HuggyClient.busy[playerObj:getDisplayName()] then return context end

    if clickedPlayer and clickedPlayer ~= playerObj and not clickedPlayer:isAsleep() and isClient() then
        local playersArgs = {
            senderID = playerObj:getOnlineID(),
            receiverID = clickedPlayer:getOnlineID(),
            senderName = playerObj:getDisplayName(),
            receiverName = clickedPlayer:getDisplayName(),
        }

        local option = context:addOption(getText("ContextMenu_Huggy" .. " " .. playersArgs.receiverName), context,
            HuggyClient.isReceiverBusy, playersArgs, playerObj, clickedPlayer)

        if math.abs(playerObj:getX() - clickedPlayer:getX()) > 3 or math.abs(playerObj:getY() - clickedPlayer:getY()) > 3 then
            option.notAvailable = true
            option.toolTipText = getText("ContextMenu_YouNeedToBeCloser")
        end

        if not option.notAvailable and playerObj:isSitOnGround() then
            option.notAvailable = true
            option.toolTipText = getText("ContextMenu_YouNeedToStandBeforeHuggy")
        end

        if option.notAvailable then
            local tooltip = ISWorldObjectContextMenu.addToolTip();
            tooltip.description = option.toolTipText;
            option.toolTip = tooltip;
        end
    end

    return context
end

HuggyClient.isReceiverBusy = function(context, playersArgs, sender, receiver)
    if math.abs(sender:getX() - receiver:getX()) > 3 or math.abs(sender:getY() - receiver:getY()) > 3 then
        return
    end

    if receiver:isSitOnGround() then
        getPlayer():SayShout(getText(receiver:getDisplayName() .. ", " .. "Please stand, I want to huggy you"))
        return
    end

    if receiver and not HuggyClient.busy[playersArgs.senderName] then
        sendClientCommand(modID, "isReceiverBusyServer", playersArgs)
    end
end
