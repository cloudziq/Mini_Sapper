extends Area2D


export(PackedScene) var _particles ;  var PARTICLES


var path         = "res://assets/graphics/tiles/tile"
var dark_color   = Color(.24, .32, .36, 1)
var reduce_mov  := false
#var texture_list
var def_pos ; var def_rot ; var def_sca


onready var	theme       = G.SETTINGS.theme
onready var	theme_data  = $"../../".theme_data[theme-1]

#onready var tween      = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)






func _ready():
	$Sprite.z_index = -2
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)

	$Sprite.flip_v = true if randf() > .5 else false
	$Sprite.flip_h = true if randf() > .5 else false

	yield(get_tree().create_timer(.004), "timeout")

	if theme_data[0] == 1:
		if theme_data[2] == false:
			$Sprite.texture = load(path + str(theme) + ".png")
		else:
			$Sprite.texture = load(path + str(theme) + "_ON.png")
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
	def_sca = scale

	position = G.gen_offscreen_pos(125)
	rotation_degrees = randi() % 361
	var a = rand_range(.8, 2.6)
	scale = Vector2(a, a)

	#1
	tween.set_parallel(true)
	a  = rand_range(.26, .64)
	tween.tween_property($".", "position", def_pos, a
		).set_ease(Tween.EASE_IN)

	tween.tween_callback($TileMain, "play").set_delay(a)

	tween.tween_property($".", "rotation_degrees", def_rot, rand_range(.20, .32)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property($".", "scale", def_sca, .4
		).set_ease(Tween.EASE_OUT)

	#2
	tween.tween_interval(.1)
	tween.set_parallel(false)
	tween.tween_property($".", "scale", def_sca * .4, .4
		).set_ease(Tween.EASE_IN)

	tween.tween_property($".", "scale", def_sca, .6
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)
	tween.tween_callback($".", "tile_finish").set_delay(.16)






func tile_finish():
	G.tiles_ready  += 1

	var num = $"../../".level_data[G.SETTINGS.level-1]
	if G.tiles_ready == (num[0] * num[1]):
#		print("ALLOW INPUT")
		$"../".allow_board_input = true

	if theme_data[2] == false:
		$Sprite.modulate = dark_color
	else:
		$Sprite.texture = load(path + str(theme) + "_OFF.png")

	animate_tile()






func animate_tile():
	var tween      = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	var pos        = def_pos
	var distance  := 3.2 if not reduce_mov else 1.6

	pos.x += rand_range(-distance, distance)
	pos.y += rand_range(-distance, distance)

#	tween.set_parallel(false)
	tween.tween_property($".", "position", pos, rand_range(4, 7)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(self, "animate_tile").set_delay(0.1)






func reveal(bombs := 0):
	if theme_data[2] == false:
		$Sprite.modulate  = Color(1,1,1,1)
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	#if tile have 0 bomb count
	var tween     := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	var delay     := rand_range(.1, .42)
	var scale_to  :  Vector2
	var trans

	if bombs == 0:
		reduce_mov  = true
		scale_to    = Vector2(.42, .42)
		trans       = Tween.TRANS_BOUNCE

		var col  = $Sprite.modulate
		col.a   *= .22
		tween.tween_property($Sprite, "modulate", col, 4
			).set_trans(Tween.TRANS_BOUNCE).set_delay(delay)
	else:
	#tile with number
		var mult    = bombs * .14
		scale_to    = Vector2(.46, .46) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC

	tween.tween_property($Sprite, "scale", scale_to, 2.6
			).set_trans(trans).set_delay(delay)

	PARTICLES = _particles.instance()
	add_child(PARTICLES)
	PARTICLES.show(bombs)

	$TileReveal.play()







func _on_Area2D_area_shape_entered(_a, _b, _c, _d):
	$"../".check_clicked_tile()
