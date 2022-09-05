-- ============================================================= --
-- EMPTY BALERS MOD
-- ============================================================= --
EmptyBalers = {};

function EmptyBalers.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Baler, specializations)
end

function EmptyBalers.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", EmptyBalers)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", EmptyBalers)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", EmptyBalers)
end

function EmptyBalers.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "emptyBaler", EmptyBalers["emptyBaler"])
end

function EmptyBalers:onLoad(savegame)
	if self.spec_emptyBalers == nil then
		self.spec_emptyBalers = {}
	end
	local spec = self.spec_emptyBalers
	spec.actionEventId = nil
	spec.emptyingEnabled = false
end

function EmptyBalers:onRegisterActionEvents(isActiveForInput)
	if self.isClient then
		local spec = self.spec_emptyBalers
		spec.actionEvents = {}

		self:clearActionEventsTable(spec.actionEvents)

		if isActiveForInput then
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.EMPTY_BALER, self, EmptyBalers.actionEventEmptyBaler, false, true, true, true, nil)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_HIGH)
			self.spec_emptyBalers.actionEventId = actionEventId
		end
	end
end

function EmptyBalers:onUpdate(dt, isActiveForInput, isSelected)
	local spec = self.spec_emptyBalers
	local baler = self.spec_baler
	if spec.actionEventId ~= nil then
		local fillLevel = self:getFillUnitFillLevelPercentage(baler.fillUnitIndex)		
		local baleIsCotton = false
		if baler.dummyBale.currentBale ~= nil then
			if baler.dummyBale.currentBaleFillType == 11 then
				baleIsCotton = true
			end
		end
		if baleIsCotton==false and table.getn(baler.bales)==0 and fillLevel>0 and fillLevel<1 then
			g_inputBinding:setActionEventActive(spec.actionEventId, true)
			spec.emptyingEnabled = true
		else
			g_inputBinding:setActionEventActive(spec.actionEventId, false)
			spec.emptyingEnabled = false
		end
	end
end

function EmptyBalers:actionEventEmptyBaler(actionName, inputValue, callbackState, isAnalog)
	if self.spec_emptyBalers.emptyingEnabled then
		local vehicle = self.selectionObject.vehicle
		self:emptyBaler(vehicle, false)
	end
end

function EmptyBalers:emptyBaler(vehicle, noEventSend)
	local spec = self.spec_emptyBalers
	local baler = self.spec_baler
	local fillUnit = self.spec_fillUnit.fillUnits[baler.fillUnitIndex]
	fillUnit.fillLevel = 0
	fillUnit.fillType = FillType.UNKNOWN
	if baler.dummyBale.currentBale ~= nil then
		self:deleteDummyBale(baler.dummyBale)
	end
	if baler.buffer.dummyBale.available then
		self:deleteDummyBale(baler.buffer.dummyBale)
	end
	baler.dummyBale.currentBale = nil
	baler.lastBaleFillLevel = 0
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(EmptyBalerEvent.new(vehicle), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(EmptyBalerEvent.new(vehicle))
		end
	end
end