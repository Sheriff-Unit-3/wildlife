local S = wildlife.S
local node_dps_dmg = wildlife.node_dps_dmg
local mob = "wildlife:deer"

local function herbivore_brain(self)
	if mobkit.timer(self, 1) then
		node_dps_dmg(self)
	end
	mobkit.vitals(self)

	if self.hp <= 0 then
		mobkit.clear_queue_high(self)
		mobkit.hq_die(self)
		return
	end

	if mobkit.timer(self, 1) then
		local prty = mobkit.get_queue_priority(self)

		if prty < 20 and self.isinliquid then
			mobkit.hq_liquid_recovery(self, 20)
			return
		end

		local pos = self.object:get_pos()

		if prty < 11 then
			local pred = mobkit.get_closest_entity(self, "wildlife:wolf")
			if pred then
				mobkit.hq_runfrom(self, 11, pred)
				return
			end
		end
		if prty < 10 then
			local plyr = mobkit.get_nearby_player(self)
			if plyr and vector.distance(pos, plyr:get_pos()) < 8 then
				mobkit.hq_runfrom(self, 10, plyr)
				return
			end
		end
		if mobkit.is_queue_empty_high(self) then
			mobkit.hq_roam(self, 0)
		end
	end
end

core.register_entity(mob, {
	physical = true,
	stepheight = 3,
	collide_with_objects = true,
	collisionbox = { -0.35, -0.19, -0.35, 0.35, 0.65, 0.35 },
	visual = "mesh",
	mesh = "herbivore.b3d",
	textures = { "herbivore.png" },
	visual_size = { x = 1.3, y = 1.3 },
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,
	on_activate = mobkit.actfunc,
	get_staticdata = mobkit.statfunc,
	springiness = 0,
	buoyancy = 0.9,
	max_speed = 5,
	jump_height = 1.26,
	view_range = 24,
	lung_capacity = 10,
	max_hp = 10,
	timeout = 600,
	attack = { range = 0.5, damage_groups = { fleshy = 3 } },
	sounds = {
		scared = "deer_scared",
		hurt = "deer_hurt",
	},
	animation = {
		walk = { range = { x = 10, y = 29 }, speed = 30, loop = true },
		stand = { range = { x = 1, y = 5 }, speed = 1, loop = true },
	},
	logic = herbivore_brain,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) then
			local hvel = vector.multiply(vector.normalize({ x = dir.x, y = 0, z = dir.z }), 4)
			self.object:set_velocity({ x = hvel.x, y = 2, z = hvel.z })
			mobkit.make_sound(self, "hurt")
			mobkit.hurt(self, tool_capabilities.damage_groups.fleshy or 1)
		end
	end,
})

wildlife.register_egg(mob, S("Deer Spawn Egg"), "wildlife_deer.png", { wildlife = 1, egg = 1, spawn_egg = 1 })
