local modname = core.get_current_modname()

local function load(file)
	return dofile(core.get_modpath(modname) .. "/" .. file)
end

wildlife = {}
wildlife.S = core.get_translator(modname)

function wildlife.node_dps_dmg(self)
	local pos = self.object:get_pos()
	local box = self.object:get_properties().collisionbox
	local pos1 = { x = pos.x + box[1], y = pos.y + box[2], z = pos.z + box[3] }
	local pos2 = { x = pos.x + box[4], y = pos.y + box[5], z = pos.z + box[6] }
	local nodes_overlap = mobkit.get_nodes_in_area(pos1, pos2)
	local total_damage = 0

	for node_def, _ in pairs(nodes_overlap) do
		local dps = node_def.damage_per_second
		if dps then
			total_damage = math.max(total_damage, dps)
		end
	end

	if total_damage ~= 0 then
		mobkit.hurt(self, total_damage)
	end
end

load("wolf.lua")
load("deer.lua")
load("spawn.lua")
