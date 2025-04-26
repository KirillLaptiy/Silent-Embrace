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
