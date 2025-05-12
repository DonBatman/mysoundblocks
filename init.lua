local player_active_cooldown = {}
local player_sound_handler = {}
local player_playing_sound = {}
local player_recent_chat = {}

local COMMAND_RADIUS = 5
local DEFAULT_COOLDOWN = 5
local DEFAULT_ACTIVATION_RADIUS = 3
local DEFAULT_HEAR_DISTANCE = 10
local DEFAULT_GAIN = 1.0

core.register_node("mysoundblocks:block", {
	description = "Sound Block",
	drawtype = "normal",
	tiles = {"mysoundblocks_block.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, not_in_creative_inventory = 0},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local player_name = placer:get_player_name()

		if not core.get_player_privs(player_name).mysoundblocks then
			core.chat_send_player(player_name, "You need the 'mysoundblocks' privilege to place this block.")
			return
		end

		core.set_node(pos, {name = "mysoundblocks:block"})

	end,

	on_dig = function(pos, node, player)
		local player_name = player:get_player_name()

		if not core.get_player_privs(player_name).mysoundblocks then
			core.chat_send_player(player_name, "You need the 'mysoundblocks' privilege to dig this block.")
			return
		end

		core.remove_node(pos)

		-- Optional: Check for ownership before allowing digging
		-- local meta = core.get_meta(pos)
		-- if meta:get_string("owner") ~= player_name and not core.get_player_privs(player_name).protection_bypass then
		--     core.chat_send_player(player_name, "You do not own this sound block.")
		--     return
		-- end
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local player_name = player:get_player_name()
		local meta = core.get_meta(pos)

		local current_sound_name = meta:get_string("sound_name") or ""
		local current_cooldown = tonumber(meta:get_string("cooldown")) or DEFAULT_COOLDOWN
		local current_radius = tonumber(meta:get_string("radius")) or DEFAULT_ACTIVATION_RADIUS
		local current_chat_message = meta:get_string("chat_message") or ""
		local current_target_mode = meta:get_string("target_mode") or "Player"
		local current_hear_distance = tonumber(meta:get_string("hear_distance")) or DEFAULT_HEAR_DISTANCE
		local current_gain = tonumber(meta:get_string("gain")) or DEFAULT_GAIN

		local target_mode_index = 1
		if current_target_mode == "All" then
			target_mode_index = 2
		end

		core.show_formspec(player_name, "mysoundblocks:config@" .. core.pos_to_string(pos),
			"size[6,7;]"..
			"background[-0.5,-0.5;7,8;mysoundblocks_bg.png]"..
			"label[0.7,0.5;Configure Sound Block]"..
			"field[1,1.5;4.5,1;sound_name;Sound Name;"..core.formspec_escape(current_sound_name).."]"..
			"field[1,2.5;4.5,1;chat_message;Chat Message;"..core.formspec_escape(current_chat_message).."]"..
			"field[1,3.5;2,1;cooldown;Cooldown (sec);"..current_cooldown.."]"..
			"field[3.5,3.5;2,1;radius;Activation Radius;"..current_radius.."]"..
			"label[0.7,3.9;Target:]"..
			"dropdown[0.7,4.2;2,1;target_mode;Player,All;"..target_mode_index.."]"..
			"field[3.5,4.5;2,1;hear_distance;Hear Distance;"..current_hear_distance.."]"..
			"field[2.75,5.5;1,1;gain;Gain (0-1);"..current_gain.."]"..
			"button_exit[0.75,6.25;1.5,1;save_sound;Sound Only]"..
			"button_exit[2.25,6.25;1.5,1;save_chat;Chat Only]"..
			"button_exit[3.75,6.25;1.5,1;save_both;Both]"
		)
	end,
})

core.register_node("mysoundblocks:block_hidden", {
	tiles = {"mysoundblocks_hidden.png"},
	drawtype = "airlike",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	groups = {not_in_creative_inventory = 1},
})

core.register_privilege("mysoundblocks", {
	description = "Allows placing and digging sound blocks",
	give_to_admin = true,
})

core.register_on_player_receive_fields(function(player, formname, fields)

	if string.find(formname, "mysoundblocks:config@") == 1 then
		local pos_str = string.sub(formname, string.len("mysoundblocks:config@") + 1)
		local pos = core.string_to_pos(pos_str)

		if not core.get_node(pos) then
			return false
		end

		local meta = core.get_meta(pos)

		local submitted_sound_name = fields.sound_name or ""
		local submitted_chat_message = fields.chat_message or ""
		local submitted_cooldown = tonumber(fields.cooldown) or DEFAULT_COOLDOWN
		local submitted_radius = tonumber(fields.radius) or DEFAULT_ACTIVATION_RADIUS
		local submitted_target_mode_index = tonumber(fields.target_mode) or 1
		local submitted_hear_distance = tonumber(fields.hear_distance) or DEFAULT_HEAR_DISTANCE
		local submitted_gain = tonumber(fields.gain) or DEFAULT_GAIN

		local submitted_target_mode = "Player"
		if submitted_target_mode_index == 2 then
			submitted_target_mode = "All"
		end

		submitted_cooldown = math.max(0, submitted_cooldown)
		submitted_radius = math.max(0, submitted_radius)
		submitted_hear_distance = math.max(0, submitted_hear_distance)
		submitted_gain = math.max(0, math.min(1, submitted_gain))

		local trigger_type = nil

		if fields.save_sound then
			trigger_type = "sound"
		elseif fields.save_chat then
			trigger_type = "chat"
		elseif fields.save_both then
			trigger_type = "both"
		end

		if trigger_type then
			meta:set_string("sound_name", submitted_sound_name)
			meta:set_string("chat_message", submitted_chat_message)
			meta:set_string("cooldown", tostring(submitted_cooldown))
			meta:set_string("radius", tostring(submitted_radius))
			meta:set_string("target_mode", submitted_target_mode)
			meta:set_string("hear_distance", tostring(submitted_hear_distance))
			meta:set_string("gain", tostring(submitted_gain))
			meta:set_string("trigger_type", trigger_type)

			core.swap_node(pos, {name = "mysoundblocks:block_hidden"})

			core.chat_send_player(player:get_player_name(), "Sound Block configured!")

			return true
		end

		return false
	end

	return false
end)

core.register_chatcommand("showsb", {
	params = "",
	description = "Show nearby hidden sound blocks",
	privs = {mysoundblocks = true},

	func = function(name, param)
		local player = core.get_player_by_name(name)

		if not player then
			return false, "Player not found"
		end

		local pos = player:getpos()

		local hidden_blocks = core.find_nodes_in_area(
			{x = pos.x - COMMAND_RADIUS, y = pos.y - COMMAND_RADIUS, z = pos.z - COMMAND_RADIUS},
			{x = pos.x + COMMAND_RADIUS, y = pos.y + COMMAND_RADIUS, z = pos.z + COMMAND_RADIUS},
			{"mysoundblocks:block_hidden"}
		)

		local count = 0
		for _, block_pos in pairs(hidden_blocks) do
			core.swap_node(block_pos, {name = "mysoundblocks:block"})
			count = count + 1
		end

		core.chat_send_player(name, "Showed " .. count .. " hidden sound block(s) nearby.")

		return true
	end
})

core.register_chatcommand("hidesb", {
	params = "",
	description = "Hide nearby visible sound blocks",
	privs = {mysoundblocks = true},

	func = function(name, param)
		local player = core.get_player_by_name(name)

		if not player then
			return false, "Player not found"
		end

		local pos = player:getpos()

		local visible_blocks = core.find_nodes_in_area(
			{x = pos.x - COMMAND_RADIUS, y = pos.y - COMMAND_RADIUS, z = pos.z - COMMAND_RADIUS},
			{x = pos.x + COMMAND_RADIUS, y = pos.y + COMMAND_RADIUS, z = pos.z + COMMAND_RADIUS},
			{"mysoundblocks:block"}
		)

		local count = 0
		for _, block_pos in pairs(visible_blocks) do
			core.swap_node(block_pos, {name = "mysoundblocks:block_hidden"})
			count = count + 1
		end

		core.chat_send_player(name, "Hid " .. count .. " visible sound block(s) nearby.")

		return true
	end
})

core.register_abm({
	nodenames = {"mysoundblocks:block_hidden"},
	interval = 0.5,
	chance = 1,
	catch_up = false,

	action = function(pos, node)
		local meta = core.get_meta(pos)

		local sound_name = meta:get_string("sound_name")
		local cooldown = tonumber(meta:get_string("cooldown")) or DEFAULT_COOLDOWN
		local radius = tonumber(meta:get_string("radius")) or DEFAULT_ACTIVATION_RADIUS
		local chat_message = meta:get_string("chat_message")
		local trigger_type = meta:get_string("trigger_type")
		local target_mode = meta:get_string("target_mode") or "Player"
		local hear_distance = tonumber(meta:get_string("hear_distance")) or DEFAULT_HEAR_DISTANCE
		local gain = tonumber(meta:get_string("gain")) or DEFAULT_GAIN

		local objects_in_range = core.get_objects_inside_radius(pos, radius)

		local global_sound_played_this_cycle = false

		for _, obj in ipairs(objects_in_range) do
			if obj:is_player() then
				local player_name = obj:get_player_name()

				if not player_active_cooldown[player_name] then

					if target_mode == "All" and (trigger_type == "sound" or trigger_type == "both") and sound_name and not global_sound_played_this_cycle then
						local sound_spec = {
							pos = pos,
							gain = gain,
						}
						local success, handler = pcall(core.sound_play, sound_name, sound_spec)
						if not success then
							core.log("warning", "[mysoundblocks] Failed to play global sound '" .. sound_name .. "' at " .. core.pos_to_string(pos) .. ": " .. tostring(handler))
						end
						global_sound_played_this_cycle = true

					end

					if (trigger_type == "chat" or trigger_type == "both") and chat_message then
						if player_recent_chat[player_name] ~= chat_message then
							core.chat_send_player(player_name, chat_message)
							player_recent_chat[player_name] = chat_message
						end
					end

					if target_mode == "Player" and (trigger_type == "sound" or trigger_type == "both") and sound_name then

						if player_sound_handler[player_name] and player_playing_sound[player_name] ~= sound_name then
							core.sound_stop(player_sound_handler[player_name])
							player_sound_handler[player_name] = nil
							player_playing_sound[player_name] = nil
						end

						if player_playing_sound[player_name] ~= sound_name then
							local sound_spec = {
								to_player = player_name,
								max_hear_distance = hear_distance,
								gain = gain,
								pos = pos,
							}
							local success, handler = pcall(core.sound_play, sound_name, sound_spec)
							if success and handler then
								player_sound_handler[player_name] = handler
								player_playing_sound[player_name] = sound_name
							else
								core.log("warning", "[mysoundblocks] Failed to play player sound '" .. sound_name .. "' for player '" .. player_name .. "' at " .. core.pos_to_string(pos) .. ": " .. tostring(handler))
							end
						end
					end

					player_active_cooldown[player_name] = true

					core.after(cooldown, function(p_name)
						player_active_cooldown[p_name] = nil
						if player_sound_handler[p_name] then
							player_sound_handler[p_name] = nil
							player_playing_sound[p_name] = nil
						end
						player_recent_chat[p_name] = nil
					end, player_name)

				end
			end
		end
	end
})

core.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	core.log("info", "[mysoundblocks] Cleaning up state for player: " .. player_name)
	player_active_cooldown[player_name] = nil
	if player_sound_handler[player_name] then
		core.sound_stop(player_sound_handler[player_name])
	end
	player_sound_handler[player_name] = nil
	player_playing_sound[player_name] = nil
	player_recent_chat[player_name] = nil
end)
