local S = wildlife.S
local node_dps_dmg = wildlife.node_dps_dmg

local function predator_brain(self)
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
		local priority = mobkit.get_queue_priority(self)
		local pos = self.object:get_pos()

		if priority < 20 and self.isinliquid then
			mobkit.hq_liquid_recovery(self, 20)
			return
		end

		-- hunt
		if priority < 10 then
			local prey = mobkit.get_closest_entity(self, "wildlife:deer")
			if prey then
				mobkit.hq_hunt(self, 10, prey)
			end
		end

		if priority < 9 then
			local player = mobkit.get_nearby_player(self)
			local objs = core.get_objects_inside_radius(pos, 15)
			local wolfs = 0
			local players = 0
			if player and vector.distance(pos, player:get_pos()) < 10 then
				for _, obj in ipairs(objs) do
					if obj:get_luaentity().name == self.object:get_luaentity().name then
						wolfs = wolfs + 1
					elseif obj:is_player() then
						players = players + 1
					end
				end
				if wolfs / players < 2 then
					mobkit.hq_runfrom(self, 9, player)
				else
					mobkit.hq_hunt(self, 10, player)
				end
			end
		end

		if mobkit.is_queue_empty_high(self) then
			mobkit.hq_roam(self, 0)
		end
	end
end

core.register_entity("wildlife:wolf", {
	physical = true,
	stepheight = 2,
	collide_with_objects = true,
	collisionbox = { -0.3, -0.01, -0.3, 0.3, 0.7, 0.3 },
	visual = "mesh",
	mesh = "wolf.b3d",
	textures = { "kit_wolf.png" },
	visual_size = { x = 1.3, y = 1.3 },
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,
	on_activate = mobkit.actfunc,
	get_staticdata = mobkit.statfunc,
	springiness = 0,
	buoyancy = 0.75,
	max_speed = 5,
	jump_height = 1.26,
	view_range = 24,
	lung_capacity = 10,
	max_hp = 14,
	timeout = 600,
	attack = { range = 0.5, damage_groups = { fleshy = 7 } },
	sounds = {
		attack = "dogbite",
		warn = "angrydog",
	},
	animation = {
		walk = { range = { x = 10, y = 29 }, speed = 30, loop = true },
		stand = { range = { x = 1, y = 5 }, speed = 1, loop = true },
	},
	logic = predator_brain,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) then
			local hvel = vector.multiply(vector.normalize({ x = dir.x, y = 0, z = dir.z }), 4)
			self.object:set_velocity({ x = hvel.x, y = 2, z = hvel.z })
			mobkit.hurt(self, tool_capabilities.damage_groups.fleshy or 1)

			if type(puncher) == "userdata" and puncher:is_player() then
				mobkit.clear_queue_high(self)
				mobkit.hq_hunt(self, 10, puncher)
			end
		end
	end,
})
