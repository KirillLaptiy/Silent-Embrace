--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

-- When click on dialog button
function SilentEmbraceClient:onButtonClick(button)
    if button.internal == "NO" then
        SilentEmbraceClient.isBusy = false

        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.declineRequest,
            SilentEmbraceClient.EmbracePlayers)

        Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
    elseif button.internal == "YES" then
        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.acceptRequest,
            SilentEmbraceClient.EmbracePlayers)
    elseif button.internal == "CANCEL" then
        SilentEmbraceClient.isBusy = false

        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.cancelRequest,
            SilentEmbraceClient.EmbracePlayers)

        Events.OnTick.Remove(SilentEmbraceClient.playersInGameCheck)
    elseif button.internal == "OK" then
        SilentEmbraceClient.isBusy = false

        sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearBusy,
            { playerName = getPlayer():getDisplayName() })
    end
end

-- Create dialog
local createModalDialog = function(label, isSelectButtons)
    local modalDialog = ISModalDialog:new(
        getCore():getScreenWidth() / 2 - 175,
        getCore():getScreenHeight() / 2 - 75,
        350,
        150,
        label,
        isSelectButtons,
        nil,
        SilentEmbraceClient.onButtonClick
    )

    SilentEmbraceClient.dialog = modalDialog

    modalDialog.moveWithMouse = true

    modalDialog:initialise()
    modalDialog:addToUIManager()

    return modalDialog
end

-- Sender dialog
SilentEmbraceClient.ModalDialogs.senderDialog = function()
    local modalDialog = createModalDialog(
        getText("IGUI_Embrace_sended") ..
        " " .. SilentEmbraceClient.EmbracePlayers.receiverName,
        false
    )

    modalDialog:removeChild(modalDialog.ok)

    local btnWid = 100
    local btnHgt = math.max(25, getTextManager():getFontHeight(UIFont.Small) + 3 * 2)
    local padBottom = 10

    modalDialog.cancel = ISButton:new((modalDialog:getWidth() / 2) - btnWid / 2,
        modalDialog:getHeight() - padBottom - btnHgt, btnWid,
        btnHgt, getText("UI_Cancel"), modalDialog, ISModalDialog.onClick)
    modalDialog.cancel.internal = "CANCEL"
    modalDialog.cancel.anchorTop = false
    modalDialog.cancel.anchorBottom = true
    modalDialog.cancel:initialise()
    modalDialog.cancel:instantiate()
    modalDialog.cancel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }

    modalDialog:addChild(modalDialog.cancel)
end

-- Receiver dialog
SilentEmbraceClient.ModalDialogs.receiverDialog = function()
    createModalDialog(getText("IGUI_Embrace_received") .. " " .. SilentEmbraceClient.EmbracePlayers.senderName,
        true)
end

-- Declined dialog
SilentEmbraceClient.ModalDialogs.declinedDialog = function(isBusy)
    if (SilentEmbraceClient.dialog) then
        SilentEmbraceClient.dialog:removeFromUIManager()
    end

    local dialogText = "IGUI_Embrace_declined"

    if isBusy then dialogText = "IGUI_Embrace_busy" end

    createModalDialog(getText(dialogText), false)
end
