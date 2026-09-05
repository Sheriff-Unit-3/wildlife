function wildlife.stack_max()
	if core.get_modpath("xcompat") then
		return xcompat.functions.get_default_stack_max()
	elseif core.get_modpath("mcl_core") then
		return 64
	else
		return tonumber(core.settings:get("default_stack_max")) or 99
	end
end

function wildlife.register_egg(mob, desc, image, groups)
	-- From Mobs Redo by TenPlus1, licensed under MIT, see LICENSE.md
	core.register_craftitem(mob .. "_egg", {
		description = desc,
		inventory_image = "wildlife_egg.png^(" .. image .. "^[mask:wildlife_egg_overlay.png)",
		groups = groups,
		stack_max = wildlife.stack_max(),
		on_place = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.above
			local under = core.get_node(pointed_thing.under)
			local def = under and core.registered_nodes[under.name]
			if not pos then
				return
			end
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack, pointed_thing)
			end
			if core.is_protected(pos, placer:get_player_name()) then
				return
			end
			local new_mob = core.add_entity(pos, mob)
			local entity = new_mob and new_mob:get_luaentity()
			if not entity then
				return
			end
			itemstack:take_item()
			return itemstack
		end,
	})
end
