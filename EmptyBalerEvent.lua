EmptyBalerEvent = {}
local EmptyBalerEvent_mt = Class(EmptyBalerEvent, Event)
InitEventClass(EmptyBalerEvent, "EmptyBalerEvent")
function EmptyBalerEvent.emptyNew()
	local self = Event.new(EmptyBalerEvent_mt)
	return self
end

function EmptyBalerEvent.new(object)
	local self = EmptyBalerEvent.emptyNew()
	self.object = object
	return self
end

function EmptyBalerEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self:run(connection)
end

function EmptyBalerEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.object)
end

function EmptyBalerEvent:run(connection)
	if not connection:getIsServer() then
		self.object:emptyBaler(self.object, true)
	else
		self.object:emptyBaler(self.object, true)
	end
end

function EmptyBalerEvent.sendEvent()
    g_client:getServerConnection():sendEvent(EmptyBalerEvent.new())
end