﻿local ghost_util = {}
ghost_util.check_limit = 20
ghost_util.ghosts = {} -- if we get desyncs investigate here
ghost_util.ghostcount = 0
--=============================================================================
-------------------------------------------------------------------------------
--	public
-------------------------------------------------------------------------------
function ghost_util.init(_, check_interval, check_limit)
	if check_interval == nil then
		check_interval = 120
	end
	if check_limit ~= nil then
		ghost_util.check_limit = check_limit
	end
	--ToDo: https://forums.factorio.com/viewtopic.php?t=57306
	script.on_nth_tick(check_interval, ghost_util.check_ghosts)
end

function ghost_util.unregister_ghost(entity)
	local key = string.format("%s:%s:%s:%d:%d", entity.surface.name, entity.force.name, entity.ghost_name,
		entity.position.x, entity.position.y)
	if ghost_util.ghosts[key] then
		ghost_util.ghosts[key] = nil
		ghost_util.ghostcount = ghost_util.ghostcount - 1
	end
end

function ghost_util.register_ghost(entity)
	local key = string.format("%s:%s:%s:%d:%d", entity.surface.name, entity.force.name, entity.ghost_name,
		entity.position.x, entity.position.y)
	ghost_util.ghosts[key] = {
		entity = entity,
		position = entity.position,
		ghost_name = entity.ghost_name,
		surface = entity.surface,
		force = entity.force,
		key = key
	}
	ghost_util.ghostcount = ghost_util.ghostcount + 1
end

function ghost_util.register_callback(callback_func)
	if callback_func == nil then error("callback function must not be null") end
	if type(callback_func) ~= "function" then error("Handler should be callable.") end
	ghost_util.callback_func = callback_func
end

-------------------------------------------------------------------------------
--	pseudo private
-------------------------------------------------------------------------------
function ghost_util.callback_func(_)
	--log("ghost_util.callback_func")
end

function ghost_util.check_ghosts()
	if ghost_util.ghostcount == 0 then
		return
	end
	for key, ghost in pairs(ghost_util.ghosts) do
		if not ghost.entity.valid then
			--log("ghost " .. key .. " became invalid")
			ghost_util.ghosts[key].entity = nil
			ghost_util.callback_func(ghost_util.ghosts[key])
			ghost_util.ghosts[key] = nil
			ghost_util.ghostcount = ghost_util.ghostcount - 1
		end
	end
end

--=============================================================================
return ghost_util
