-- ============================================================= --
-- EMPTY BALERS MOD
-- ============================================================= --
local modDir = g_currentModDirectory
g_specializationManager:addSpecialization('emptyBalers', 'EmptyBalers', Utils.getFilename('EmptyBalers.lua', modDir), '');
for name, data in pairs(g_vehicleTypeManager:getTypes()) do
	--local vehicleType = g_vehicleTypeManager:getTypeByName(tostring(name));
	if SpecializationUtil.hasSpecialization(Baler, data.specializations) then
		g_vehicleTypeManager:addSpecialization(name, 'emptyBalers')
	end
end
source(modDir .. "EmptyBalerEvent.lua")