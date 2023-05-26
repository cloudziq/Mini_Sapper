extends Node2D


export(PackedScene) var _tile ;  var TILE
export(PackedScene) var _bomb ;  var BOMB
export(PackedScene) var _label ; var LABEL
export(PackedScene) var _touch ; var TOUCH

export var zoom_speed = .1
export var max_zoom   = 4.00
export var min_zoom   = 0.25

#export var textures_ready = false


onready var tile_size = get_parent().tile_size_in_pixels




var bombs_amount       := 4
var tiles_left         :  int
var board_size         :  Vector2
var tile_coord         :  Vector2
var hold_touch_time    := 0.0
var allow_board_input  := true
var target_zoom        := Vector2(1.0, 1.0)
var window             := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)


# tile status:
# 0: unrevealed
# 1: contains a bomb
# 2: revealed
# 3: detector tile
# [tile_id, marker_id, bomb_id, counter_id], tile_status, bomb_count]
var board_data         :  Array





func _ready():
	print("LEVEL is ready")
	print(window)
	board_size = Vector2(10, 16)
	generate_board()





func _process(delta):
	if OS.get_system_time_msecs() >= hold_touch_time and hold_touch_time != 0:
		hold_touch_time = 0

	if $Camera2D.zoom != target_zoom:
		$Camera2D.zoom = lerp($Camera2D.zoom, target_zoom, zoom_speed * 20 * delta)




func _input(event):
	var tile_is_valid = true
	var pos = get_viewport().get_mouse_position()

	if allow_board_input and event.is_pressed():
		var x = ceil((pos.x - (window.x - (board_size.x * tile_size)) / 2) / tile_size)
		var y = ceil((pos.y - (window.y - (board_size.y * tile_size)) / 2) / tile_size)
		tile_coord = Vector2(x, y)
		if not (x == clamp(x, 1, board_size.x) and y == clamp(y, 1, board_size.y)):
			tile_is_valid = false

	if tile_is_valid and event is InputEventScreenTouch:
		if event.is_pressed():
			hold_touch_time = OS.get_system_time_msecs() + 444
		elif not event.is_pressed() and hold_touch_time != 0:
			hold_touch_time = 0
			TOUCH = _touch.instance() ; add_child(TOUCH)
			TOUCH.position = pos

	#camera zooming:
	if event.is_action_pressed("zoom+"):
		target_zoom -= Vector2(zoom_speed, zoom_speed)
	elif event.is_action_pressed("zoom-"):
		target_zoom += Vector2(zoom_speed, zoom_speed)






func check_clicked_tile():
	if allow_board_input:
		var tile_stat = board_data[tile_coord.x -1][tile_coord.y - 1][1]

		#### CHECK TILE
		if tile_stat == 0:
			tile_reveal(tile_coord, null, null)
#			$Sounds/TileReveal.pitch = rand_range(.8, 1.4)
#			$Sounds/TileReveal.play()
		elif tile_stat == 1:
			game_over()
			print("YOU DIED!")




func game_over():
	for x in board_size.x:
		for y in board_size.y:
			if board_data[x][y][1] == 1:
				var tile_rotation = board_data[x][y][0][0].rotation
				board_data[x][y][0][2].reveal_bomb(tile_rotation)




var near_coords = [
	[-1, -1], [0, -1], [1, -1],
	[-1,  0],          [1,  0],
	[-1,  1], [0,  1], [1,  1]
]

func tile_reveal(coord, neighbours_table = [], count = 0):
	var cx
	var cy

	tiles_left -= 1
	if tiles_left == 0:
		pass
		#level_complete()




#function tile_reveal(x, y, detector, neighbours_table, count)
#	local cx, cy, particle_type
#	local detector = detector or false
#	local neighbours_table = neighbours_table or {}
#	local count = count or 0    -- for multi tiles reveal sound only
#
#	tiles_left = tiles_left - 1
#	msg.post("/gui#level", "update display", {type = "tile", amount = tiles_left})
#
#	if not detector then
#		board_data[x][y][2] = 2
#	else
#		gen_num(x, y, detector)
#		board_data[x][y][2] = 3
#	end
#
#	if tiles_left == 0 then
#		level_complete()
#	end
#
#	if reveal_sound_allow and count > 0 then
#		reveal_sound_allow = false
#		sound.play("/sound#reveal_main")
#		sound.play("/sound#reveal_distant", {gain = 2.4 + G_settings.music_vol})
#	end
#
#	for index, value in ipairs(near_coords) do
#		cx = x + value[1]
#		cy = y + value[2]
#
#		if (cx >= 1 and cx <= board_tiles_x) and (cy >= 1 and cy <= board_tiles_y) then
#			if board_data[x][y][3] == 0 and board_data[cx][cy][2] ~= 1 then
#				table.insert(neighbours_table, {cx, cy})
#			else
#				msg.post(board_data[x][y][1][4], "reveal digit", {rot = go.get(board_data[x][y][1][1], "euler.z")})
#			end
#		end
#	end
#
#	if #neighbours_table == 0 then
#		particle_type = ""
#	else
#		-- process neighbours:
#		for index, _ in ipairs(neighbours_table) do
#			local x = neighbours_table[index][1]
#			local y = neighbours_table[index][2]
#
#			-- process only unrevealed tiles
#			if board_data[x][y][2] == 0 then
#				tile_reveal(x, y, false, neighbours_table, count + 1)
#			end
#		end
#		particle_type = "_multi"
#	end
#
#	-- remove markers
#	if board_data[x][y][1][2] ~= 0 then
#		msg.post(board_data[x][y][1][2], "delete")
#		board_data[x][y][1][2] = 0
#		markers = markers - 1
#	end
#
#	msg.post(board_data[x][y][1][1], "reveal tile", {type = particle_type, detector = detector, parent = board_data[x][y][1][1]})
#end


func generate_board():
	var x_def = (window.x - (board_size.x * tile_size)) / 2 + (tile_size / 2)
	var y_def = (window.y - (board_size.y * tile_size)) / 2 + (tile_size / 2)
	var pos = Vector2(x_def, y_def)

	board_data = []

	#### GENERATE BOARD:
	for x in board_size.x:
		board_data.push_back([])

		for y in board_size.y:
			TILE = _tile.instance() ; add_child(TILE)
			TILE.position = pos
			TILE.scale = Vector2(.25, .25)
			pos.y += tile_size
			board_data[x].append([[TILE, 0, 0, 0], 0, 0])
		pos.x += tile_size
		pos.y = y_def

	#### GENERATE BOMBS:
	pos = gen_pos()
	for a in bombs_amount:
		while board_data[pos.x][pos.y][1] == 1: pos = gen_pos()
		board_data[pos.x][pos.y][1] = 1
#		var x = x_def + (pos.x * tile_size)
#		var y = y_def + (pos.y * tile_size)
		BOMB = _bomb.instance()
		board_data[pos.x][pos.y][0][0].add_child(BOMB)
		board_data[pos.x][pos.y][0][2] = BOMB
#		bomb.position = Vector2(x, y)
#		bomb.scale = Vector2(.25, .25)

	#### GENERATE NUMBERS:
	for x in board_size.x:
		for y in board_size.y:
			if board_data[x][y][1] != 1:
				gen_num(x, y)




func gen_pos():
	var x = floor(rand_range(1, board_size.x))
	var y = floor(rand_range(1, board_size.y))
	return Vector2(x, y)




func gen_num(x, y):
	var counter = 0

	for index in near_coords:
		var cx = x + index[0]
		var cy = y + index[1]

		if (cx >= 0 and cx <= board_size.x - 1) and (cy >= 0 and cy <= board_size.y - 1):
			if board_data[cx][cy][1] == 1:
				counter = counter + 1

	if counter > 0:
		if board_data[x][y][0][3] == 0:
			LABEL = _label.instance() ; board_data[x][y][0][0].add_child(LABEL)
		LABEL.text = str(counter)
		board_data[x][y][0][3] = LABEL

	board_data[x][y][2] = counter
