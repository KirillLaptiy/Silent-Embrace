--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

local createHuggyContext = ISWorldObjectContextMenu.createMenu

ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = createHuggyContext(player, worldobjects, x, y, test)

    local playerObj = getSpecificPlayer(player)

    if SilentEmbraceClient.isBusy then return context end

    if clickedPlayer and clickedPlayer ~= playerObj and not clickedPlayer:isAsleep() and isClient() then
        local playersArgs = {
            senderID = playerObj:getOnlineID(),
            receiverID = clickedPlayer:getOnlineID(),
            senderName = playerObj:getDisplayName(),
            receiverName = clickedPlayer:getDisplayName(),
        }

        local option = context:addOption(getText("ContextMenu_Embrace") .. " " .. playersArgs.receiverName, context,
            SilentEmbraceClient.isReceiverBusy, playersArgs, playerObj, clickedPlayer)

        if math.abs(playerObj:getX() - clickedPlayer:getX()) > 3 or math.abs(playerObj:getY() - clickedPlayer:getY()) > 3 then
            option.notAvailable = true
            option.toolTipText = getText("ContextMenu_Embrace_YouNeedToBeCloser")
        end

        if not option.notAvailable and playerObj:isSitOnGround() then
            option.notAvailable = true
            option.toolTipText = getText("ContextMenu_YouNeedToStand")
        end

        if option.notAvailable then
            local tooltip = ISWorldObjectContextMenu.addToolTip();
            tooltip.description = option.toolTipText;
            option.toolTip = tooltip;
        end
    end

    return context
end

SilentEmbraceClient.isReceiverBusy = function(_, playersArgs, sender, receiver)
    if math.abs(sender:getX() - receiver:getX()) > 3 or math.abs(sender:getY() - receiver:getY()) > 3 then
        return
    end

    if receiver:isSitOnGround() then
        getPlayer():SayShout(receiver:getDisplayName() .. ", " .. getText("ContextMenu_Embrace_get_up"))
        return
    end

    if not SilentEmbraceClient.isBusy then
        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.sendRequest, playersArgs)
    end
end
