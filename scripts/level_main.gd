extends Node2D


export(PackedScene) var _tile ;  var tile
export(PackedScene) var _bomb ;  var bomb
export(PackedScene) var _label ; var label
export(PackedScene) var _touch ; var touch

export var textures_ready = false


var tile_size
var bombs_amount = 10
var board_size
var TILE = Vector2()    #### HOLDS TILE UNDER CURSOR
var allow_board_input = true
var hold_input_time = 0
var window = OS.window_size


# tile status:
# 0: unrevealed
# 1: contains a bomb
# 2: revealed
# 3: detector tile
# [tile_id, marker_id, bomb_id, counter_id], tile_status, bomb_count]
var board_data





func _ready():
	tile_size = get_node("../../Main").tile_size_in_pixels
	board_size = Vector2(10, 16)
	generate_board()




func _process(delta):
	if OS.get_system_time_msecs() >= hold_input_time and hold_input_time != 0:
		hold_input_time = 0




func _input(event):
	var tile_is_valid = true
	var x ; var y
	var pos = get_viewport().get_mouse_position()

	if allow_board_input and event.is_pressed():
		TILE.x = ceil((pos.x - (window.x - (board_size.x * tile_size)) / 2) / tile_size)
		TILE.y = ceil((pos.y - (window.y - (board_size.y * tile_size)) / 2) / tile_size)
		if TILE.x < 0 or TILE.x > board_size.x or TILE.y < 0 or TILE.y > board_size.y:
			tile_is_valid = false

	if tile_is_valid and event is InputEventScreenTouch:
		if event.is_pressed():
			hold_input_time = OS.get_system_time_msecs() + 444
		elif not event.is_pressed() and hold_input_time != 0:
			hold_input_time = 0
			touch = _touch.instance() ; add_child(touch)
			touch.position = pos





func check_clicked_tile():
	if allow_board_input:
		var tile_stat = board_data[TILE.x -1][TILE.y - 1][1]

		#### CHECK TILE
		if tile_stat == 0:
			tile_reveal(TILE.x, TILE.y, null, null)
#			$Sounds/TileReveal.pitch = rand_range(.8, 1.4)
#			$Sounds/TileReveal.play()
		elif tile_stat == 1:
			game_over()
			print("YOU DIED")




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

func tile_reveal(x, y, neighbours_table, count):
	pass



func generate_board():
	var x_def = (window.x - (board_size.x * tile_size)) / 2 + (tile_size / 2)
	var y_def = (window.y - (board_size.y * tile_size)) / 2 + (tile_size / 2)
	var pos = Vector2(x_def, y_def)
	board_data = []

	#### GENERATE BOARD:
	for x in board_size.x:
		board_data.push_back([])

		for y in board_size.y:
			tile = _tile.instance() ; add_child(tile)
			tile.position = pos
			tile.scale = Vector2(.25, .25)
			pos.y += tile_size
			board_data[x].append([[tile, 0, 0, 0], 0, 0])
		pos.x += tile_size
		pos.y = y_def

	#### GENERATE BOMBS:
	pos = gen_pos()
	for a in bombs_amount:
		while board_data[pos.x][pos.y][1] == 1: pos = gen_pos()
		board_data[pos.x][pos.y][1] = 1
#		var x = x_def + (pos.x * tile_size)
#		var y = y_def + (pos.y * tile_size)
		bomb = _bomb.instance() ; board_data[pos.x][pos.y][0][0].add_child(bomb)
		board_data[pos.x][pos.y][0][2] = bomb
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
			label = _label.instance() ; board_data[x][y][0][0].add_child(label)
		label.text = str(counter)
		board_data[x][y][0][3] = label

	board_data[x][y][2] = counter
