require "TimedActions/ISBaseTimedAction"

ISHuggyTimedAction = ISBaseTimedAction:derive("ISHuggyTimedAction")

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
	sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll, SilentEmbraceClient.EmbracePlayers)
	ISBaseTimedAction.stop(self)
end

function ISHuggyTimedAction:perform()
	sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll, SilentEmbraceClient.EmbracePlayers)
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

local function WalkToHuggy()
	local treeSquare = SilentEmbraceClient.EmbracePlayers.character:getCurrentSquare():Has(IsoObjectType.tree)

	if treeSquare == false then
		SilentEmbraceClient.EmbracePlayers.character:setGhostMode(true)
	else
		SilentEmbraceClient.EmbracePlayers.character:setGhostMode(false)
	end

	if SilentEmbraceClient.EmbracePlayers.character:pressedMovement(false) or SilentEmbraceClient.EmbracePlayers.character:pressedCancelAction() or SilentEmbraceClient.EmbracePlayers.character:pressedAim() then
		sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearAll, SilentEmbraceClient.EmbracePlayers)
		return
	end

	local distanceX = math.abs(SilentEmbraceClient.EmbracePlayers.character:getX() -
	SilentEmbraceClient.EmbracePlayers.huggingCharacter:getX())
	local distanceY = math.abs(SilentEmbraceClient.EmbracePlayers.character:getY() -
	SilentEmbraceClient.EmbracePlayers.huggingCharacter:getY())

	if distanceX <= 0.4 and distanceY <= 0.4 then
		ISTimedActionQueue.clear(SilentEmbraceClient.EmbracePlayers.character)
		ISTimedActionQueue.add(ISHuggyTimedAction:new(SilentEmbraceClient.EmbracePlayers.character,
			SilentEmbraceClient.EmbracePlayers.huggingCharacter))
		Events.OnTick.Remove(WalkToHuggy)
	end
end

Events.OnServerCommand.Add(function(module, command, args)
	if not module == SilentEmbrace.ModID then return end

	if command == "clearAll" then
		getPlayer():setGhostMode(false)
		Events.OnTick.Remove(WalkToHuggy)
	end

	if not (command == "startHugSender" or command == "startHugReceiver") then return end

	if command == "startHugSender" then
		SilentEmbraceClient.EmbracePlayers.character = getPlayerByOnlineID(args.senderID)
		SilentEmbraceClient.EmbracePlayers.huggingCharacter = getPlayerByOnlineID(args.receiverID)
	else
		SilentEmbraceClient.EmbracePlayers.character = getPlayerByOnlineID(args.receiverID)
		SilentEmbraceClient.EmbracePlayers.huggingCharacter = getPlayerByOnlineID(args.senderID)
	end

	ISTimedActionQueue.clear(SilentEmbraceClient.EmbracePlayers.character)
	ISTimedActionQueue.add(ISWalkToHuggy:new(SilentEmbraceClient.EmbracePlayers.character,
		SilentEmbraceClient.EmbracePlayers.huggingCharacter:getSquare()))
	Events.OnTick.Add(WalkToHuggy)
end)
