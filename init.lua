local function load(file)
	return dofile(core.get_modpath(core.get_current_modname()) .. "/" .. file)
end

load("api.lua")
load("wolf.lua")
load("deer.lua")
load("spawn.lua")
