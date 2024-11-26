local lib_warehouse = require("__nco-LongWarehouses__/lib/lib_warehouse")
local data_util = require("__nco-LongWarehouses__/lib/data_util")
-------------------------------------------------------------------------------------
-- On Blueprint Item Replace to Reset Item to Item-Proxy
-------------------------------------------------------------------------------------
local function on_blueprint(event)
	--log("on_blueprint")
	local player = game.players[event.player_index]
	local bp = player.blueprint_to_setup
	if not bp or not bp.valid_for_read then
		bp = player.cursor_stack
	end
	if not bp or not bp.valid_for_read then
		return
	end
	local entities = bp.get_blueprint_entities()
	if not entities then
		return
	end
	for idx, e in ipairs(entities) do
		local whType = lib_warehouse.checkEntityName(e.name)
		if data_util.has_value({ "horizontal", "vertical" }, whType) then
			--log("save inventory filters, requests for h/v. A proxy copied from a ghost should have inherited the tags")
			local searchResult = player.surface.find_entities_filtered({
				force = e.force,
				name = e.name,
				position = e.position,
				radius = 0.001
			})
			--log(#searchResult)
			for _, ent in pairs(searchResult) do
				log("ent.prototype.type: " .. serpent.block(ent.prototype.type))
				-- Logistic Filters
				local requests = {}
				local flags = {}
				if tostring(ent.prototype.type) == "logistic-container" then
					log("Evaluating Logistic Filters")
					local logistic_point = ent.get_logistic_point(0)
					--log("sections_count" .. serpent.block(logistic_point.sections_count))
					for sectionIndex = 1, logistic_point.sections_count, 1 do
						local logistic_section = logistic_point.get_section(sectionIndex)
						--log("logistic_section" .. serpent.block(logistic_section))
						if (logistic_section.is_manual) then
							local section_export = {
								group = logistic_section.group,
								multiplier = logistic_section.multiplier,
								logistic_filters = {}
							}
							for slotIndex = 1, logistic_section.filters_count, 1 do
								local slot = logistic_section.get_slot(slotIndex)
								--log("slot" .. serpent.block(slot))
								table.insert(section_export.logistic_filters, {
									import_from = slot.import_from.name,
									min = slot.min,
									max = slot.max,
									value = {
										comparator = slot.value.comparator,
										name = slot.value.name,
										quality = slot.value.quality
									}
								})
							end
							table.insert(requests, section_export)
						end
					end
				end
				-- logistic Filter
				local logistic_filter = {}
				if ent.filter_slot_count and ent.filter_slot_count > 0 then
					local filter = ent.get_filter(1)
					if (filter) then
						logistic_filter = {
							comparator = filter.comparator,
							name = filter.name.name, -- name is ItemId which resolves (here) to ItemPrototype
							quality = filter.quality.name -- like name
						}
					end
				end

				if (ent.prototype.logistic_mode == "requester") then
					flags.request_from_buffers = ent.request_from_buffers
				end

				-- Locked Slots
				local inventory = ent.get_inventory(defines.inventory.chest)
				local bar = (inventory.get_bar() <= #inventory and inventory.get_bar() or nil)
				e.tags = {
					logistic_requests = (not data_util.is_empty_table(requests) and requests or nil),
					logistic_filter = (not data_util.is_empty_table(logistic_filter) and logistic_filter or nil),
					flags = (not data_util.is_empty_table(flags) and flags or nil),
					bar = bar
				}
				log("set blueprint entity tags for " ..
					ent.name .. " to:" .. serpent.block(e.tags, { comment = false, numformat = '%1.8g', compact = true }))
			end
			--log("change to proxy")
			if whType == "horizontal" then
				e.name = e.name:gsub("-h", "-proxy")
			elseif whType == "vertical" then
				e.name = e.name:gsub("-v", "-proxy")
				e.direction = defines.direction.west
			end
		end
	end
	bp.set_blueprint_entities(entities)
end
-------------------------------------------------------------------------------------
local es = defines.events
script.on_event(es.on_player_setup_blueprint, on_blueprint)
