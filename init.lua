local block_sounds = {}
local player_name = {}
local handler = {}
local sound = {}
local chats = {}

core.register_node("mysoundblocks:block", {
	description = "Sound Block",
	drawtype = "normal",
	tiles = {"mysoundblocks_block.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {oddly_breakable_by_hand = 1, not_in_creative_inventory = 0},

	on_place = function(itemstack, placer, pointed_thing)
	local pos = pointed_thing.above

		if core.get_player_privs(placer:get_player_name()).mysoundblocks ~= true then

			core.chat_send_player(placer:get_player_name(),
				"You need the mysoundblocks priv")
			return
		end

		if core.get_player_privs(placer:get_player_name()).mysoundblocks == true then
			core.set_node(pos,{name = "mysoundblocks:block"})
		end

	end,


	on_dig = function(pos, node, player)

		if core.get_player_privs(player:get_player_name()).mysoundblocks ~= true then

			core.chat_send_player(player:get_player_name(),
				"You need the mysoundblocks priv")
			return
		end

		if core.get_player_privs(player:get_player_name()).mysoundblocks == true then

			core.remove_node(pos)
		end

	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)

		local node = core.get_node(pos)
		local meta = core.get_meta(pos)
		local aa = meta:get_string("a")
		local bb = tonumber(meta:get_string("b")) or 5
		local cc = tonumber(meta:get_string("c")) or 3
		local dd = meta:get_string("d")
		local ee = tonumber(meta:get_string("e")) or 10
		local ff = tonumber(meta:get_string("e")) or 1

		core.show_formspec(player:get_player_name(),"fs",
				"size[6,7;]"..
				"background[-0.5,-0.5;7,8;mysoundblocks_bg.png]"..
				"field[1,1;4.5,1;snd;Enter Sound Name;"..aa.."]"..
				"field[1,2;4.5,1;txt;Enter Chat Message;"..dd.."]"..
				"field[1,3;2,1;sndl;Length;"..bb.."]"..
				"field[3.5,3;2,1;sndhd;Radius;"..cc.."]"..
				"label[0.7,3.4;Player or All]"..
				"dropdown[0.7,3.8;2,1;pora;Player,All;]"..
				"field[3.5,4;2,1;snddis;Hear Distance;"..ee.."]"..
				"field[2.75,5;1,1;sndgn;Gain;"..ff.."]"..
				"button_exit[0.75,5.75;1.5,1;ents;Sound]"..
				"button_exit[2.25,5.75;1.5,1;entc;Chat]"..
				"button_exit[3.75,5.75;1.5,1;entb;Both]")

		core.register_on_player_receive_fields(function(player, formname, fields)

			local meta = core.get_meta(pos)
			local inv = meta:get_inventory()
			local thing1 = fields["snd"]
			local thing2 = fields["sndl"]
			local thing3 = fields["sndhd"]
			local thing4 = fields["txt"]
			local thing5 = ""
			local thing6 = fields["pora"]
			local thing7 = fields["snddis"]
			local thing8 = fields["sndgn"]

			if fields["ents"]
			or fields["entc"]
			or fields["entb"]
			or fields["snd"]
			or fields["txt"] then

				if fields["ents"]
				and fields["snd"] ~= "" then

					meta:set_string("a", thing1)
					meta:set_string("b", thing2)
					meta:set_string("c", thing3)
					meta:set_string("d", thing4)
					meta:set_string("e", "sound")
					meta:set_string("f", thing6)
					meta:set_string("g", thing7)
					meta:set_string("h", thing8)

					core.swap_node(pos, {name = "mysoundblocks:block_hidden"})

					return true

				elseif fields["entc"]
				and fields["txt"] ~= "" then

					meta:set_string("a", thing1)
					meta:set_string("b", thing2)
					meta:set_string("c", thing3)
					meta:set_string("d", thing4)
					meta:set_string("e", "chat")

					core.swap_node(pos, {name = "mysoundblocks:block_hidden"})

					return true

				elseif fields["entb"]
				and fields["txt"] ~= ""
				and fields["snd"] ~= "" then

					meta:set_string("a", thing1)
					meta:set_string("b", thing2)
					meta:set_string("c", thing3)
					meta:set_string("d", thing4)
					meta:set_string("e", "both")
					meta:set_string("f", thing6)
					meta:set_string("g", thing7)
					meta:set_string("h", thing8)

					core.swap_node(pos, {name = "mysoundblocks:block_hidden"})

					return true
				end

			else
				return
			end
		end)

end

})

core.register_node("mysoundblocks:block_hidden", {
	tiles = {"mysoundblocks_hidden.png"},
	drawtype = "airlike",
	paramtype = "light",
	walkable = false,
	pointable = false,
	group = {not_in_creative_inventory = 1},
})

core.register_privilege("mysoundblocks", "Lets you place and dig soundblocks")

core.register_chatcommand("showsb", {
	params = "",
	description = "Show the sound block",
	privs={mysoundblocks = true},

	func = function(name, param)

		local player = core.get_player_by_name(name)

		if not player then
			return false, "Player not found"
		end

		local pos = player:getpos()

		local a = core.find_nodes_in_area(
			{x = pos.x - 5, y = pos.y - 5, z = pos.z - 5},
			{x = pos.x + 5, y = pos.y + 5, z = pos.z + 5},
			{"mysoundblocks:block_hidden"})

			for _, row in pairs(a) do
				core.swap_node(row, {name = "mysoundblocks:block"})
			end

	end
})

core.register_chatcommand("hidesb", {
	params = "",
	description = "Hide the sound block",
	privs = {mysoundblocks = true},

	func = function(name, param)

		local player = core.get_player_by_name(name)

		if not player then
			return false, "Player not found"
		end

		local pos = player:getpos()
			pos.y = pos.y + 1

		local a = core.find_nodes_in_area(
			{x = pos.x - 5, y = pos.y - 5, z = pos.z - 5},
			{x = pos.x + 5, y = pos.y + 5, z = pos.z + 5},
			{"mysoundblocks:block"})

			for _, row in pairs(a) do
				core.swap_node(row, {name = "mysoundblocks:block_hidden"})
			end

	end
})

core.register_abm({
	nodenames = {"mysoundblocks:block_hidden"},
	interval = 0.2,
	chance = 1,
	catch_up = false,

	action = function(pos, node)

		local meta = core.get_meta(pos)

		local block_sound = meta:get_string("a")
		local block_time = tonumber(meta:get_string("b"))
		local rad_dist = tonumber(meta:get_string("c"))
		local block_text = meta:get_string("d")
		local sound_chat = meta:get_string("e")
		local sound_pa = meta:get_string("f")
		local sound_dis = meta:get_string("g")
		local sound_gain = meta:get_string("h")

		-- if block_time is nil then it uses default of 5
		block_time = block_time or 5

		rad_dist = rad_dist or 3

		local all_objects = core.get_objects_inside_radius(pos, rad_dist)
		local p
		local glob = nil

		for _,obj in ipairs(all_objects) do

			if obj:is_player() then

				p = obj:get_player_name()

				if not player_name[p] then

					player_name[p] = block_sound
					if player_name[p] ~= blockname then player_name[p] = nil end

-- play sound for everyone to hear
if sound_pa == "All"
and glob == nil then

	core.sound_play(block_sound, {
		gain = sound_gain,
	})

	-- changes to true so global sound plays only once for ALL players
	glob = true
end

-- display text
if (sound_chat == "chat" or sound_chat == "both")
and block_text 
and block_text ~= chats[p] then

	core.chat_send_player(p, block_text)
	chats[p] = block_text
end

-- play sound
if (sound_chat == "sound" or sound_chat == "both")
and block_sound then

	-- stop any sounds still playing
	if handler[p] and block_sound ~= sound[p] then
		core.sound_stop(handler[p])
		if player_name[p] then core.chat_send_all(player_name[p].." and "..block_sound) end
	end

	-- only player hears this sound
	if handler[p] and block_sound == sound[p] then return end
	handler[p] = core.sound_play(block_sound, {
		max_hear_distance = sound_dis,
		to_player = p,
		gain = sound_gain,
	})
	sound[p] = block_sound

end

					core.after(block_time, function(p)
						player_name[p] = nil
					end, p)

				end
			end
		end
	end
})

