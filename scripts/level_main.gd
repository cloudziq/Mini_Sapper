extends Node2D


@export var _tile: PackedScene
@export var _bomb: PackedScene
@export var _label: PackedScene
@export var _marker: PackedScene
@export var _touch: PackedScene    ;  var TOUCH:Node2D


var tile_size          :  int
var bombs_amount       :  int
var marker_amount      :  int
var tiles_left         :  int
var board_size         :  Vector2
var tile_coord         :  Vector2
var board_center       :  Vector2
var hold_touch_time    := 0.0
var sound_timeout      := 0.0
var allow_board_input  := false
var num_tiles          := 0    # helper_var
var player_fail        :  bool


var tile_bounce_sounds = [
	preload("res://assets/sounds/tile_bounce/tile_bounce1.ogg"),
	preload("res://assets/sounds/tile_bounce/tile_bounce2.ogg"),
	preload("res://assets/sounds/tile_bounce/tile_bounce3.ogg")

]


@onready var shader_unrevealed  = preload("res://assets/shaders/glow.gdshader")



################################################################################
var board_data         :  Array
# board_data contents:
# [tile_id, marker_id, bomb_id, label_id], *tile_status, bomb_count]
# *tile status:
# 0: standard (unrevealed)
# 1: contains a bomb
# 2: empty (revealed)
# 3: ????
################################################################################






func _ready() -> void:
	var level      = G.CONFIG.level-1
	var val_1      = get_parent().level_data[level][0]
	var val_2      = get_parent().level_data[level][1]

	board_size     = Vector2(val_1, val_2)
	num_tiles      = int(val_1 *val_2)    # just helper var for child objects
	tile_size      = get_parent().tile_size_in_pixels

	$GUI.get_node("VBoxContainer/Lower/Button/Label").text  = "RESTART"

	board_center   = G.board_center_define(
		$ZoomCam, "new_pos", board_size, tile_size)

	generate_tile_instances()
	generate_board()






func _process(_dt) -> void:
	if $ZoomCam.is_moving:    # cancels marker creation
		hold_touch_time  =  0

	if hold_touch_time > 0:
		if Time.get_ticks_msec() > hold_touch_time:
			hold_touch_time  = -1
			if not TOUCH:  add_touch()






func _input(event) -> void:
	if allow_board_input:
		if event is InputEventScreenTouch:
			if event.is_pressed():
				hold_touch_time  = Time.get_ticks_msec() + 500

			elif not event.is_pressed() and not $ZoomCam.is_moving and hold_touch_time > 0:
					hold_touch_time  = 0
					if not TOUCH:  add_touch()

		elif event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				hold_touch_time  = -1
				if not TOUCH:  add_touch()






####>> some touching ;)
func add_touch() -> void:
	var pos        := get_global_mouse_position()

	TOUCH           = _touch.instantiate()
	TOUCH.position  = pos
	add_child(TOUCH)
	await get_tree().create_timer(.1).timeout
	TOUCH.queue_free()
	TOUCH           = null






#### called from 'touch object' collision
func check_clicked_tile() -> void:
	var pos := get_global_mouse_position()
	var x    = floor((pos.x -(G.window.x -(board_size.x *tile_size)) /2) /tile_size)
	var y    = floor((pos.y -(G.window.y -(board_size.y *tile_size)) /2) /tile_size)
	var shake_speed_scale : float = .8

	#setup:
	if x == clamp(x, 0, board_size.x-1) and y == clamp(y, 0, board_size.y-1):
		tile_coord = Vector2(x, y)
	var tile_data = board_data[tile_coord.x][tile_coord.y]
	var tile_stat = tile_data[1]


	if hold_touch_time >= 0:    #if tile is clicked but not when 'hold = -1'

		if not tile_data[0][1]:
			if tile_data[1] == 0:
				$sounds/TileRevealSingle.play()
				tile_reveal(tile_coord)
			elif tile_data[1] == 1:
				game_over(tile_coord)

		#tile_helper:
		var i : float
		if tile_stat == 0 or tile_data[0][1]:
			i  = shake_speed_scale * .8
		else:
			i  = shake_speed_scale

#		if tile_stat == 2:
		tile_helper_remove(100)
		tile_helper_add(tile_coord, i)

	else:    # when hold
		if tile_data[1] < 2:  add_marker()




#		bombs_amount += get_parent().level_data[a][2]


func add_marker() -> void:    # result of check_clicked_tile()
	var pos  := get_global_mouse_position()
	var x     = floor((pos.x -(G.window.x -(board_size.x *tile_size)) /2) /tile_size)
	var y     = floor((pos.y -(G.window.y -(board_size.y *tile_size)) /2) /tile_size)
	var node  = board_data[x][y][0][1]

	if board_data[x][y][1] < 2:
		if not node:
			node           = _marker.instantiate()
			marker_amount += 1
			board_data[x][y][0][0].add_child(node)
			board_data[x][y][0][1]   = node
			$sounds/TileMarker.pitch_scale  = 3.22
			node.tint_type = true if board_data[x][y][1] == 1 else false
		else:
			marker_amount -= 1
			board_data[x][y][0][1].queue_free()
			board_data[x][y][0][1]   = null
			$sounds/TileMarker.pitch_scale  = 6.48

	$sounds/TileMarker.play()
	hold_touch_time  = 0
	$GUI.update()






func generate_tile_instances() -> void:
	var node  : Area2D

	board_data  = []
	for x in board_size.x:
		board_data.append([])
		for y in board_size.y:
			node  = _tile.instantiate()
			add_child(node)
			board_data[x].append([[node, null, null, null], 0, 0])






func generate_board() -> void:
	var x_def := (G.window.x -(board_size.x *tile_size)) /2 +(tile_size /2)
	var y_def := (G.window.y -(board_size.y *tile_size)) /2 +(tile_size /2)
	var pos   := Vector2(x_def, y_def)
	var TILE  :  Node2D
	var BOMB  :  Node2D

	#reset stuff:
	G.tiles_ready  = 0
	bombs_amount   = 0
	sound_timeout  = 0.0

	#### TILE PLACEMENT:
	for x in board_size.x:
		for y in board_size.y:
			TILE  = board_data[x][y][0][0]

			TILE.def_pos   = pos
			TILE.scale     = Vector2(.25, .25)

			pos.y         += tile_size
			board_data[x][y] = [[TILE, null, null, null], 0, 0]

			### glow material applied:
			#var mat    := ShaderMaterial.new()
			#mat.gdshader  = shader_unrevealed
			#mat.set_shader_parameter("radius", -8)
			#mat.set_shader_parameter("amount", 8)
			#TILE.get_node("%Sprite2D").material  = mat
			TILE.get_node("%Sprite2D").visible   = true
			TILE.io_anim()

		pos.x += tile_size
		pos.y  = y_def


	#### GENERATE BOMBS:
	for a in G.CONFIG.level:
		bombs_amount  += get_parent().level_data[a][2]

	tiles_left = int(board_size.x *board_size.y -bombs_amount)

	pos  = gen_pos()
	for a in bombs_amount:
		while board_data[pos.x][pos.y][1] == 1:
			pos  = gen_pos()
		board_data[pos.x][pos.y][1]  = 1
		BOMB  = _bomb.instantiate()
		board_data[pos.x][pos.y][0][2]  = BOMB
		board_data[pos.x][pos.y][0][0].add_child(BOMB)


	#### GENERATE NUMBERS:
	for x in board_size.x:
		for y in board_size.y:
			if board_data[x][y][1] != 1:    #### if tile contains no bomb
				gen_num(x, y)

	$GUI.update(1)






#### from reset button or explosion:
func reset_board(force:=false) -> void:
	hold_touch_time    = 0
	allow_board_input  = false

	if not player_fail or force:
		get_tree().call_group("label",  "queue_free")
		get_tree().call_group("bomb",   "queue_free")
		get_tree().call_group("marker", "queue_free")
		get_tree().call_group("tile_particle", "queue_free")
#		get_tree().call_group()
		tile_helper_remove(16)

		for i in get_tree().get_nodes_in_group("tile"):
			i.get_node("%Sprite2D").visible  = true
			i.tweens_disable()
			i.set_physics_process(false)

		$GUI.get_node("VBoxContainer/Lower/Button/Label").text  = "RESTART"
		generate_board()
	else:
		board_data[tile_coord.x][tile_coord.y][0][2].explosion_visuals()






func level_complete() -> void:
	G.CONFIG.level += 1
#	get_tree().call_group("tile", "tweens_disable")
	get_tree().call_group("tile", "queue_free")
	await get_tree().create_timer(.2).timeout
#	reset_board()
	_ready()






func game_over(tile : Vector2) -> void:
#	allow_board_input  = false    ##-TEMPORARY DISABLED
	player_fail        = true

	get_tree().call_group("bomb"  , "reveal_bomb")
	get_tree().call_group("marker", "color_tint")

	board_data[tile.x][tile.y][0][2].bomb_anim()
	$GUI.get_node("VBoxContainer/Lower/Button/Label").text  = "CONTINUE"






var near_coords := [
	[-1, -1], [0, -1], [1, -1],
	[-1,  0],          [1,  0],
	[-1,  1], [0,  1], [1,  1]
]


func tile_reveal(coord:Vector2, neighbours:=[], count:=0, single_tile:=false) -> void:
	var tx : int
	var ty : int

	match count:
		2:
			$sounds/TileRevealMedium.pitch_scale += randf_range(-.4, .4)
			$sounds/TileRevealMedium.play()
		22:
			$sounds/TileRevealBig.pitch_scale    += randf_range(-.08, .08)
			$sounds/TileRevealBig.play()

	tiles_left -= 1
	$GUI.update()

	if tiles_left == 0:
		level_complete()

	var tile_og  = board_data[coord.x][coord.y]

	# reveal tile:
	tile_og[0][0].reveal(tile_og[2])

	# reveal label:
	if tile_og[1] == 0 and tile_og[2] > 0:
		tile_og[0][3].reveal()

	# remove marker:
	if tile_og[0][1]:
		marker_amount -= 1
		tile_og[0][1].remove()
		tile_og[0][1]  = null

	# mark tile as 'revealed'
	tile_og[1]  = 2

	# create neighbours table:
	if not single_tile:
		for index in near_coords:
			tx = coord.x + index[0]
			ty = coord.y + index[1]

			if tx == clamp(tx, 0, board_size.x-1) and ty == clamp(ty, 0, board_size.y-1):
				var tile       = board_data[tx][ty]
				if tile_og[2] == 0 and tile[1] == 0:
					neighbours.append(Vector2(tx, ty))

		# process every newly found neighbour unrevealed tile :S
		for index in neighbours:
			var x = index.x
			var y = index.y

			if board_data[x][y][1] == 0:
				tile_reveal(Vector2(x, y), neighbours, count+1)






func tile_helper_add(coord:Vector2, shake_speed_scale:float) -> void:
	var data : Array = board_data[coord.x][coord.y]

	if G.CONFIG.tile_helper and data[2] > 0 and data[1] == 2:
		var tx : int
		var ty : int

		$sounds/TileBump.pitch_scale  = .68 +randf_range(-.06, .06)
		$sounds/TileBump.play()

		# create new tile_bumps:
		for index in near_coords:
			tx = coord.x + index[0]
			ty = coord.y + index[1]

			if tx == clamp(tx, 0, board_size.x-1) and ty == clamp(ty, 0, board_size.y-1):
				if board_data[tx][ty][1] < 2:
					var node = board_data[tx][ty]
					node[0][0].tile_helper_spawn()

	# shake only the clicked tile (with number)
	var node  = board_data[coord.x][coord.y][0][0]
	node.og_tile_shake_anim(int(4*shake_speed_scale), shake_speed_scale)






func tile_helper_remove(speed_scale:= 1.0) -> void:
	# remove previous tile_helper highlights:
	for node in get_tree().get_nodes_in_group("tile_bump"):
		node.remove_from_group("tile_bump")
		node.tween.set_speed_scale(speed_scale)
	for node in get_tree().get_nodes_in_group("tile_particle"):
		node.remove_from_group("tile_particle")
		node.tween.set_speed_scale(speed_scale)







func reveal_starter_tiles() -> void:
	for a in get_parent().level_data[G.CONFIG.level-1][3]:
		var pos := gen_pos()
		while board_data[pos.x][pos.y][2] == 0:
			pos  = gen_pos()

		tile_reveal(pos, [], 0, true)






#func reveal_empty_tiles() -> void:
#	var node  : Area2D
#
#	board_data  = []
#	for x in board_size.x:
#		for y in board_size.y:
#			node  = board_data[x][y][0][0]







func gen_pos() -> Vector2:
	var x = floor(randf_range(0, board_size.x))
	var y = floor(randf_range(0, board_size.y))
	return Vector2(x, y)






func gen_num(x, y) -> void:
	var LABEL   :  CenterContainer
	var counter := 0

	for index in near_coords:
		var cx = x + index[0]
		var cy = y + index[1]

		if cx == clamp(cx, 0, board_size.x-1) and cy == clamp(cy, 0, board_size.y-1):
			if board_data[cx][cy][1] == 1:    #if near tile have a bomb
				counter += 1

	if counter > 0:
		LABEL                         = _label.instantiate()
		board_data[x][y][0][3]        = LABEL
		board_data[x][y][2]           = counter
		board_data[x][y][0][0].add_child(LABEL)    #assign as a child of tile

		if counter != 1:
			LABEL.get_node("Label").text  = str(counter)
		else:
			LABEL.get_node("Label").text  = "I"
