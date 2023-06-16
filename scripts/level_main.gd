extends Node2D


export(PackedScene) var _tile ;  var TILE
export(PackedScene) var _bomb ;  var BOMB
export(PackedScene) var _label ; var LABEL
export(PackedScene) var _touch ; var TOUCH


#export var textures_ready = false

var tile_size          :  int
var bombs_amount       :  int
var tiles_left         :  int
var board_size         :  Vector2
var tile_coord         :  Vector2
var hold_touch_time    := 0.0
var allow_board_input  := false


# board_data contents:
# [tile_id, marker_id, bomb_id, label_id], tile_status, bomb_count]
# tile status:
# 0: unrevealed
# 1: contains a bomb
# 2: revealed
# 3: detector tile
var board_data         :  Array






func _ready():
	var level        = G.SETTINGS.level-1
	var val_1        = $"../".level_data[level][0]
	var val_2        = $"../".level_data[level][1]
	board_size       = Vector2(val_1, val_2)
	tile_size        = $"../".tile_size_in_pixels
	bombs_amount     = $"../".level_data[G.SETTINGS.level-1][2]
	tiles_left       = int(board_size.x * board_size.y - bombs_amount)
	generate_board()






func _process(_delta):
	if OS.get_system_time_msecs() >= hold_touch_time and hold_touch_time != 0:
		hold_touch_time = 0






func _input(event):
	var tile_is_valid  := true
	var pos            := get_global_mouse_position()

	if allow_board_input:
		#check if tile is valid:
		if event.is_pressed():
			var x  = ceil((pos.x - (G.window.x - (board_size.x * tile_size)) / 2) / tile_size)
			var y  = ceil((pos.y - (G.window.y - (board_size.y * tile_size)) / 2) / tile_size)

			if not (x == clamp(x, 1, board_size.x) and y == clamp(y, 1, board_size.y)):
				tile_is_valid = false
			else:
				tile_coord = Vector2(x, y)


		if tile_is_valid and event is InputEventScreenTouch:
			if event.is_pressed():
				hold_touch_time    = OS.get_system_time_msecs() + 444
			elif not event.is_pressed() and hold_touch_time != 0:
				hold_touch_time    = 0
				TOUCH              = _touch.instance()
				TOUCH.position     = pos
				add_child(TOUCH)






func check_clicked_tile():
	if allow_board_input:
		var tile_stat = board_data[tile_coord.x-1][tile_coord.y-1][1]

		#### CHECK TILE
		if tile_stat == 0:
			$TileReveal.play()
			tile_reveal(tile_coord, [])
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

func tile_reveal(coord : Vector2, neighbours_table := []):
	var tx ; var ty

	coord -= Vector2(1,1)
	tiles_left -= 1

	if tiles_left == 0:
		print("LEVEL COMPLETED!")
		#level_complete()
#		return


	#reveal label:
	if board_data[coord.x][coord.y][1] == 0 and board_data[coord.x][coord.y][2] > 0:
		var angle = board_data[coord.x][coord.y][0][0].rotation_degrees
		board_data[coord.x][coord.y][0][3].reveal(angle)


	for index in near_coords:
		tx = coord.x + index[0]
		ty = coord.y + index[1]

#		if (tx >= 0 and tx <= board_size.x-1) and (ty >= 0 and ty <= board_size.y-1):
		if tx == clamp(tx, 0, board_size.x-1) and ty == clamp(ty, 0, board_size.y-1):
			if board_data[coord.x][coord.y][2] == 0 and board_data[tx][ty][1] == 0:
				neighbours_table.append(Vector2(tx, ty))

	board_data[coord.x][coord.y][1] = 2    #mark tile as 'revealed'


#	if neighbours_table.size() == 0:
#		# for particles later
#		pass
#	else:
	for index in neighbours_table:
		var x = index.x
		var y = index.y

		#process only unrevealed tiles
		if board_data[x][y][1] == 0:
			tile_reveal(Vector2(x+1, y+1), neighbours_table)
#		particle_type = "_multi"

	board_data[coord.x][coord.y][0][0].reveal(board_data[coord.x][coord.y][2])






func generate_board():
	var x_def = (G.window.x - (board_size.x * tile_size)) / 2 + (tile_size / 2)
	var y_def = (G.window.y - (board_size.y * tile_size)) / 2 + (tile_size / 2)
	var pos = Vector2(x_def, y_def)

	board_data = []
	G.tiles_ready = 0

	#### GENERATE TILES:
	for x in board_size.x:
		board_data.push_back([])

		for y in board_size.y:
			TILE            = _tile.instance()
			TILE.position   = pos
			TILE.scale      = Vector2(.25, .25)
			pos.y          += tile_size
			board_data[x].append([[TILE, 0, 0, 0], 0, 0])
			add_child(TILE)
		pos.x += tile_size
		pos.y = y_def

	#### GENERATE BOMBS:
	pos = gen_pos()
	for a in bombs_amount:
		while board_data[pos.x][pos.y][1] == 1:
			pos = gen_pos()
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
			if board_data[x][y][1] != 1:   #if tile have no bomb
				gen_num(x, y)






func gen_pos():
	var x = floor(rand_range(0, board_size.x))
	var y = floor(rand_range(0, board_size.y))
	return Vector2(x, y)






func gen_num(x, y):
	var counter = 0

	for index in near_coords:
		var cx = x + index[0]
		var cy = y + index[1]

		if (cx >= 0 and cx <= board_size.x-1) and (cy >= 0 and cy <= board_size.y-1):
#		if not (cx == clamp(cx, 1, board_size.x) and cy == clamp(cy, 1, board_size.y)):
			if board_data[cx][cy][1] == 1:    #if tile has a bomb
				counter = counter + 1

	if counter > 0 and board_data[x][y][0][3] == 0:    #if there no label assigned
		LABEL                         = _label.instance()
		board_data[x][y][0][0]         .add_child(LABEL)    #assign as a child of tile
		board_data[x][y][0][3]        = LABEL
		board_data[x][y][2]           = counter
		LABEL.get_node("Label").text  = str(counter)
