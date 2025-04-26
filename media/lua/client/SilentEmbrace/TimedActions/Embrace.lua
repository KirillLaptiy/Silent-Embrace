--[[
*
*              ^_^         Y U M M Y         ^_^
*
*                 ~ Deliciously Made by YUMMY ~
*
*                          :3  :3  :3
*
]]

require "TimedActions/ISBaseTimedAction"

ISHuggyTimedAction = ISBaseTimedAction:derive("ISHuggyTimedAction")

local everyEmbraceMinute = function()
	local player = getPlayer()

	-- Set stats
	local stats = player:getStats()

	local stress = stats:getStress()
	local boredom = stats:getBoredom()
	local panic = stats:getPanic()
	local pain = stats:getPain()
	local hunger = stats:getHunger()
	local thirst = stats:getThirst()

	if player:getTraits():contains("TenderHeart") then
		stress = stress - 0.1
		boredom = boredom - 0.1
		panic = panic - 0.1
		pain = pain - 0.1
		hunger = hunger - 0.00011
		thirst = thirst - 0.00011
	elseif player:getTraits():contains("Heartbreaker") then
		stress = stress + 0.05
		boredom = boredom + 0.05
	else
		stress = stress - 0.03
		boredom = boredom - 0.03
		panic = panic - 0.03
	end

	stats:setStress(stress)
	stats:setBoredom(boredom)
	stats:setPanic(panic)
	stats:setPain(pain)
	stats:setHunger(hunger)
	stats:setThirst(thirst)
end

local controlPlayersDirection = function(sender, receiver)
	local s_x, s_y = sender:getX(), sender:getY()
	local r_x, r_y = receiver:getX(), receiver:getY()

	local vectorSender = Vector2.new(r_x - s_x, r_y - s_y)
	sender:setForwardDirection(vectorSender)

	local vectorReceiver = Vector2.new(s_x - r_x, s_y - r_y)
	receiver:setForwardDirection(vectorReceiver)
end

function ISHuggyTimedAction:isValid()
	return not self.character:isDriving()
end

function ISHuggyTimedAction:waitToStart()
	controlPlayersDirection(self.character, self.receiver)
	return self.character:shouldBeTurning() and not self.character:isMoving() and not self.receiver:isMoving()
end

function ISHuggyTimedAction:update()
	controlPlayersDirection(self.receiver, self.character)
end

function ISHuggyTimedAction:start()
	self.character:setGhostMode(false)

	if self.character:isFemale() then
		self:setActionAnim("kate_embrace")
	else
		self:setActionAnim("bob_embrace")
	end

	Events.EveryOneMinute.Add(everyEmbraceMinute)
end

function ISHuggyTimedAction:stop()
	sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearEmbrace, SilentEmbraceClient.EmbracePlayers)

	Events.EveryOneMinute.Remove(everyEmbraceMinute)

	ISBaseTimedAction.stop(self)
end

function ISHuggyTimedAction:perform()
	sendClientCommand(SilentEmbrace.ModID, SilentEmbrace.Commands.clearEmbrace, SilentEmbraceClient.EmbracePlayers)

	Events.EveryOneMinute.Remove(everyEmbraceMinute)

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

	o.forceProgressBar = false
	o.maxTime = -1

	return o
end
