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

ISWalkToHuggy = ISBaseTimedAction:derive("ISWalkToHuggy");

function ISWalkToHuggy:isValid()
    if self.character:getVehicle() then return false end
    return getGameSpeed() <= 2;
end

function ISWalkToHuggy:update()
    self.result = self.character:getPathFindBehavior2():update();

    if self.result == BehaviorResult.Failed then
        self:forceStop();
        return;
    end

    if self.additionalTest ~= nil then
        if self.additionalTest(self.additionalContext) then
            self:forceComplete();
            return
        end
    end
    if self.result == BehaviorResult.Succeeded then
        self:forceComplete();
    end
end

function ISWalkToHuggy:start()
    self.character:getPathFindBehavior2():pathToLocation(self.location:getX(), self.location:getY(), self.location:getZ());
end

function ISWalkToHuggy:stop()
    ISBaseTimedAction.stop(self);
    self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);
end

function ISWalkToHuggy:perform()
    self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);

    ISBaseTimedAction.perform(self);

    if self.onCompleteFunc then
        local args = self.onCompleteArgs
        self.onCompleteFunc(args[1], args[2], args[3], args[4])
    end
end

function ISWalkToHuggy:setOnComplete(func, arg1, arg2, arg3, arg4)
    self.onCompleteFunc = func
    self.onCompleteArgs = { arg1, arg2, arg3, arg4 }
end

function ISWalkToHuggy:new(character, location, additionalTest, additionalContext)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;

    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = -1;
    o.location = location;
    o.pathIndex = 0;
    o.additionalTest = additionalTest;
    o.additionalContext = additionalContext;
    return o
end
