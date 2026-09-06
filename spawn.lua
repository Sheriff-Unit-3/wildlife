local abr = core.get_mapgen_setting("active_block_range")
local min = math.min
local max = math.max
local spawn_rate = 1 - max(min(core.settings:get("wildlife.spawn_chance") or 0.2, 1), 0)
local spawn_reduction = core.settings:get("wildlife.spawn_reduction") or 0.5

local function spawnstep(dtime)
	for _, plyr in ipairs(core.get_connected_players()) do
		if math.random() < dtime * 0.2 then
			local vel = plyr:get_player_velocity()
			local spd = vector.length(vel)
			local chance = spawn_rate * 1 / (spd * 0.75 + 1)

			local yaw
			if spd > 1 then
				yaw = plyr:get_look_horizontal() + math.random() * 0.35 - 0.75
			else
				yaw = math.random() * math.pi * 2 - math.pi
			end
			local pos = plyr:get_pos()
			local dir = vector.multiply(core.yaw_to_dir(yaw), abr * 16)
			local pos2 = vector.add(pos, dir)
			pos2.y = pos2.y - 5
			local height, liquidflag = mobkit.get_terrain_height(pos2, 32)

			if
				height
				and height >= 0
				and not liquidflag
				and mobkit.nodeatpos({ x = pos2.x, y = height - 0.01, z = pos2.z }).is_ground_content
			then
				local objs = core.get_objects_inside_radius(pos, abr * 16 + 5)
				local wcnt = 0
				local dcnt = 0
				for _, obj in ipairs(objs) do -- count mobs in abrange
					if not obj:is_player() then
						local luaent = obj:get_luaentity()
						if luaent and luaent.name:find("wildlife:") then
							chance = chance + (1 - chance) * spawn_reduction -- chance reduced for every mob in range
							if luaent.name == "wildlife:wolf" then
								wcnt = wcnt + 1
							elseif luaent.name == "wildlife:deer" then
								dcnt = dcnt + 1
							end
						end
					end
				end
				if chance < math.random() then
					local mobname = dcnt > wcnt + 1 and "wildlife:wolf" or "wildlife:deer"

					pos2.y = height + 0.5
					objs = core.get_objects_inside_radius(pos2, abr * 16 - 2)
					for _, obj in ipairs(objs) do
						if obj:is_player() then
							return
						end
					end
					core.add_entity(pos2, mobname)
				end
			end
		end
	end
end

core.register_globalstep(spawnstep)
