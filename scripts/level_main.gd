extends Node2D


export(PackedScene) var _tile
export(PackedScene) var _bomb
export(PackedScene) var _label
export(PackedScene) var _marker
export(PackedScene) var _touch  ;  var TOUCH : Node2D


#export var textures_ready = false

var tile_size          :  int
var bombs_amount       :  int
var marker_amount      :  int
var tiles_left         :  int
var board_size         :  Vector2
var tile_coord         :  Vector2
var hold_touch_time    := 0.0
var allow_board_input  := false
var player_fail        := false


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
	marker_amount    = 0
	generate_board()






func _process(_dt):

	# triggering a marker:
		if OS.get_system_time_msecs() > hold_touch_time and hold_touch_time > 0:
			if not $ZoomCam.is_moving:
				hold_touch_time  = -1
				if not TOUCH:
					add_touch()
			else:
				hold_touch_time  = 0





func _input(event):
	var pos            := get_global_mouse_position()

	if allow_board_input and event is InputEventScreenTouch:

		if event.is_pressed():
#			print("pressed")
			var x  = ceil((pos.x - (G.window.x - (board_size.x * tile_size)) / 2) / tile_size)
			var y  = ceil((pos.y - (G.window.y - (board_size.y * tile_size)) / 2) / tile_size)

			if x == clamp(x, 1, board_size.x) and y == clamp(y, 1, board_size.y):
				tile_coord = Vector2(x, y)
				hold_touch_time    = OS.get_system_time_msecs() + 500

		elif not event.is_pressed() and not $ZoomCam.is_moving and hold_touch_time > 0:
#			print("released")
			hold_touch_time    = 0
			if not TOUCH:
				add_touch()






func check_clicked_tile():    # called from touch collision
	var tile_stat = board_data[tile_coord.x-1][tile_coord.y-1][1]

	if hold_touch_time >= 0:    #if tile is clicked but not when 'hold = (-1)'
		if tile_stat == 0:
			$TileReveal.play()
			tile_reveal(tile_coord, [])
	#			$Sounds/TileReveal.pitch = rand_range(.8, 1.4)
	#			$Sounds/TileReveal.play()
		elif tile_stat == 1:
			game_over()
			print("YOU DIED!")
	else:
		add_marker()






func add_touch():
#	print("touch!")
	var pos        := get_global_mouse_position()

	TOUCH           = _touch.instance()
	TOUCH.position  = pos
	add_child(TOUCH)
	yield(get_tree().create_timer(.1), "timeout")
	TOUCH.queue_free()
	TOUCH            = null






func add_marker():
	var pos  := get_global_mouse_position()
	var x     = ceil((pos.x - (G.window.x - (board_size.x * tile_size)) / 2) / tile_size) -1
	var y     = ceil((pos.y - (G.window.y - (board_size.y * tile_size)) / 2) / tile_size) -1
	var node  = board_data[x][y][0][1]

	if board_data[x][y][1] < 2:
		if not node:
			marker_amount += 1
			node  = _marker.instance()
			board_data[x][y][0][0].add_child(node)
			board_data[x][y][0][1]  = node
		else:
			marker_amount -= 1
			board_data[x][y][0][1].queue_free()
			board_data[x][y][0][1]  = null
		$GUI.update()

	hold_touch_time  = -1




func game_over():
	var tile_rot  : float

	for x in board_size.x:
		for y in board_size.y:
			if board_data[x][y][1] == 1:
				tile_rot  = board_data[x][y][0][0].rotation
				board_data[x][y][0][2].reveal_bomb(tile_rot)






var near_coords = [
	[-1, -1], [0, -1], [1, -1],
	[-1,  0],          [1,  0],
	[-1,  1], [0,  1], [1,  1]
]

func tile_reveal(coord : Vector2, neighbours_table := []):
	var tx ; var ty

	coord      -= Vector2(1,1)
	tiles_left -= 1
	$GUI.update()

	if tiles_left == 0:
		print("LEVEL COMPLETED!")
		#level_complete()
#		return

	#reveal tile:
	board_data[coord.x][coord.y][0][0].reveal(board_data[coord.x][coord.y][2])

	#reveal label:
	if board_data[coord.x][coord.y][1] == 0 and board_data[coord.x][coord.y][2] > 0:
		var angle = board_data[coord.x][coord.y][0][0].rotation_degrees
		board_data[coord.x][coord.y][0][3].reveal(angle)

	#remove markers:
	if board_data[coord.x][coord.y][0][1]:
		marker_amount -= 1
		board_data[coord.x][coord.y][0][1].queue_free()
		board_data[coord.x][coord.y][0][1]  = null

	board_data[coord.x][coord.y][1]  = 2    #mark tile as 'revealed'

	for index in near_coords:
		tx = coord.x + index[0]
		ty = coord.y + index[1]

		if tx == clamp(tx, 0, board_size.x-1) and ty == clamp(ty, 0, board_size.y-1):
			if board_data[coord.x][coord.y][2] == 0 and board_data[tx][ty][1] == 0:
				neighbours_table.append(Vector2(tx, ty))

	# process every tiles:
	for index in neighbours_table:
		var x = index.x
		var y = index.y

		#process only unrevealed tiles:
		if board_data[x][y][1] == 0:
			tile_reveal(Vector2(x+1, y+1), neighbours_table)





func generate_board():
	var x_def = (G.window.x - (board_size.x * tile_size)) / 2 + (tile_size / 2)
	var y_def = (G.window.y - (board_size.y * tile_size)) / 2 + (tile_size / 2)
	var pos   = Vector2(x_def, y_def)
	var TILE  : Node2D
	var BOMB  : Node2D

	board_data     = []
	G.tiles_ready  =  0
	$GUI.update()

	#### GENERATE TILES:
	for x in board_size.x:
		board_data.append([])

		for y in board_size.y:
			TILE           = _tile.instance()
			TILE.position  = pos
			TILE.scale     = Vector2(.25, .25)
			pos.y         += tile_size
			add_child(TILE)
			board_data[x].append([[TILE, null, null, null], 0, 0])
		pos.x += tile_size
		pos.y = y_def

	#### GENERATE BOMBS:
	pos = gen_pos()
	for a in bombs_amount:
		while board_data[pos.x][pos.y][1] == 1:
			pos = gen_pos()
		board_data[pos.x][pos.y][1]  = 1
		BOMB  = _bomb.instance()
		board_data[pos.x][pos.y][0][2]  = BOMB
		board_data[pos.x][pos.y][0][0].add_child(BOMB)

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
	var counter  = 0
	var LABEL    : CenterContainer

	for index in near_coords:
		var cx = x + index[0]
		var cy = y + index[1]

#		if (cx >= 0 and cx <= board_size.x-1) and (cy >= 0 and cy <= board_size.y-1):
		if (cx == clamp(cx, 0, board_size.x-1) and cy == clamp(cy, 0, board_size.y-1)):
			if board_data[cx][cy][1] == 1:    #if tile has a bomb
				counter = counter + 1

	if counter > 0:
		LABEL                         = _label.instance()
		board_data[x][y][0][0].add_child(LABEL)    #assign as a child of tile
		board_data[x][y][2]           = counter
		board_data[x][y][0][3]        = LABEL
		LABEL.get_node("Label").text  = str(counter)
