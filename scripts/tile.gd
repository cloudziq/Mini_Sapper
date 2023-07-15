extends Area2D

var test_num  := 0
export(PackedScene) var _particles ;  var PARTICLES


var path         = "res://assets/graphics/tiles/TILE_"
var dark_color   = Color(.24, .32, .36, 1)
var reduce_mov  := false    #for 'empty revealed' tiles
#var texture_list
var def_pos ; var def_rot ; var def_sca


onready var	theme       = G.SETTINGS.theme
onready var	theme_data  = $"../../".theme_data[theme-1]

var tween      : SceneTreeTween






func _ready():
	$Sprite.z_index = -2
	tween  = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)

	$Sprite.flip_v = true if randf() > .5 else false
	$Sprite.flip_h = true if randf() > .5 else false

	yield(get_tree().create_timer(.004), "timeout")

	$Sprite.modulate = dark_color
	if theme_data[0] == 1:
		if theme_data[2] == false:
			$Sprite.texture = load(path + str(theme) + ".png")
		else:
			$Sprite.texture = load(path + str(theme) + "_OFF.png")
	else:
		var num = randi() % theme_data[0] + 1
		$Sprite.texture = load(path + str(theme) +"_"+ str(num) + ".png")

	if theme_data[1] == 1:
		rotation_degrees = 90 if randf() > .5 else 0
	else:
		rotation_degrees = rand_range(0, 360)


	#### START LEVEL TILES ANIMATION:
	def_pos = position
	def_rot = rotation_degrees
	def_sca = scale * 0.92

	position = G.gen_offscreen_pos(125)
	rotation_degrees = randi() % 361
	var a = rand_range(.8, 3.6)
	scale = Vector2(a, a)

	#1
	tween.set_parallel(true)
	a  = rand_range(.26, .64)
	tween.tween_property(self, "position", def_pos, a
		).set_ease(Tween.EASE_IN)

	tween.tween_callback($TileMain, "play").set_delay(a)

	tween.tween_property(self, "rotation_degrees", def_rot, rand_range(.20, .32)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", def_sca, .4
		).set_ease(Tween.EASE_OUT)

	#2
	tween.tween_interval(.12)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", def_sca * .4, .4
		).set_ease(Tween.EASE_IN)

	tween.tween_property(self, "scale", def_sca, .6
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)
	tween.tween_callback(self, "tile_finish").set_delay(.16)






func tile_finish():
	G.tiles_ready  += 1
	var num = $"../../".level_data[G.SETTINGS.level-1]

	if G.tiles_ready == (num[0] * num[1]):
		$"../".allow_board_input  = true
		G.tiles_ready             = 0
		animate_tile(-1)
	else:
		animate_tile()

	if theme_data[2] == false:
		$Sprite.modulate  = Color(1,1,1,1)
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	yield(get_tree().create_tween().tween_interval(.25), "finished")
	animate_tile(1)






# type:
#  -1  : init
#	0  : position
#	1  : rotation

func animate_tile(type := 0) -> void:
#	var tween      = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	var pos        = def_pos
	var rot        = def_rot

	if tween and type == -1:
		tween.kill()
	tween      = get_tree().create_tween()

	if type == 0:
		var distance  := 3.2 if not reduce_mov else 1.6
		pos.x         += rand_range(-distance, distance)
		pos.y         += rand_range(-distance, distance)

		tween.tween_property(self, "position", pos, rand_range(6, 8)
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(self, "animate_tile").set_delay(.2)
	else :
		var angle  := 22
		rot        += rand_range(-angle, angle)

		tween.tween_property(self, "rotation_degrees", rot, rand_range(6, 10)
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(self, "animate_tile", [1]).set_delay(.2)






func show_near_tiles(coord : Vector2) -> void:
	var near_coords  = $"../".near_coords
	var tx           : int
	var ty           : int

	for index in near_coords:
		tx = coord.x + index[0]
		ty = coord.y + index[1]






func reveal(counter := 0) -> void:
	var col

	if theme_data[2] == false:
		$Sprite.modulate  = dark_color
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	if tween:  tween.kill()
	tween      = get_tree().create_tween().set_parallel(true)

	var delay     := rand_range(.12, .28)
	var scale_to  :  Vector2
	var trans

	if counter == 0:
	#if tile have 0 bomb count
		reduce_mov  = true
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		col         = $Sprite.modulate

		if $Sprite.material.blend_mode == BLEND_MODE_MIX:
			col.a *= .22
		else:
			col.a *= .36

		tween.tween_property($Sprite, "modulate", col, 3.25
			).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)

	else:
	#if tile have any number
		var mult    = counter * .024
		scale_to    = Vector2(.14, .14) + Vector2(mult, mult)
		trans       = Tween.TRANS_BOUNCE

		PARTICLES = _particles.instance()
		add_child(PARTICLES)
#		PARTICLES.show(counter)

	tween.tween_property(self, "scale", scale_to, 3.25
		).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)






func _on_Area2D_area_shape_entered(_a, _b, _c, _d):
	$"../".check_clicked_tile()
	_b.set_deferred("monitorable", false)






func _exit_tree():
	queue_free()
