
require "TimedActions/ISBaseTimedAction"

ISHuggyTimedAction = ISBaseTimedAction:derive("ISHuggyTimedAction")

local modID = "Huggies"
local huggingPlayers = {}

function ISHuggyTimedAction:isValid()
	return not self.character:isDriving()
end

function ISHuggyTimedAction:waitToStart()
	self.character:faceThisObject(self.receiver)
	return self.character:shouldBeTurning()
end

function ISHuggyTimedAction:update()
	self.character:faceThisObject(self.receiver)
end

function ISHuggyTimedAction:start()

	self.character:setGhostMode(false)

	print("Hugging!")
	self:setActionAnim("AnimationGuide")
	-- self:setActionAnim("Huggy")
end

function ISHuggyTimedAction:stop()
	sendClientCommand(modID, "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
	ISBaseTimedAction.stop(self)
end

function ISHuggyTimedAction:perform()
	sendClientCommand(modID, "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
	ISBaseTimedAction.perform(self)
end

function ISHuggyTimedAction:new(sender, receiver)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = sender
	o.receiver = receiver
	o.stopOnWalk = true
	o.stopOnRun = true
	o.stopOnAim = true

	o.forceProgressBar = true
	o.maxTime = 1400

	return o
end

local function WalkToHuggy ()
	local treeSquare = huggingPlayers.character:getCurrentSquare():Has(IsoObjectType.tree)

	if treeSquare == false then
		huggingPlayers.character:setGhostMode(true)
	else
		huggingPlayers.character:setGhostMode(false)
	end

	if huggingPlayers.character:pressedMovement(false) or huggingPlayers.character:pressedCancelAction() or huggingPlayers.character:pressedAim() then
		sendClientCommand(modID, "clearBusyAfterHuggyActionServer", HuggingPlayersArgs)
		return
	end

	local distanceX = math.abs(huggingPlayers.character:getX() - huggingPlayers.huggingCharacter:getX())
	local distanceY = math.abs(huggingPlayers.character:getY() - huggingPlayers.huggingCharacter:getY())

	if distanceX <= 0.4 and distanceY <= 0.4 then
		ISTimedActionQueue.clear(huggingPlayers.character)
		ISTimedActionQueue.add(ISHuggyTimedAction:new(huggingPlayers.character, huggingPlayers.huggingCharacter))
		Events.OnTick.Remove(WalkToHuggy)
	end
end

Events.OnServerCommand.Add(function(module, command, args)
	if not module == modID then return end

	if command == "clearBusyAfterHuggyActionClient" then
		getPlayer():setGhostMode(false)
		Events.OnTick.Remove(WalkToHuggy)
	end

	if not (command == "onAcceptedHuggyRequestSender" or command == "onAcceptHuggyRequestReceiver") then return end

	if command == "onAcceptedHuggyRequestSender" then
		huggingPlayers.character = getPlayerByOnlineID(args.senderID)
		huggingPlayers.huggingCharacter = getPlayerByOnlineID(args.receiverID)
	else
		huggingPlayers.character = getPlayerByOnlineID(args.receiverID)
		huggingPlayers.huggingCharacter = getPlayerByOnlineID(args.senderID)
	end

	ISTimedActionQueue.clear(huggingPlayers.character)
	ISTimedActionQueue.add(ISWalkToHuggy:new(huggingPlayers.character, huggingPlayers.huggingCharacter:getSquare()))
	Events.OnTick.Add(WalkToHuggy)
end)