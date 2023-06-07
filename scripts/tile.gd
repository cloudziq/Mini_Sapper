extends Area2D


var path = "res://assets/graphics/tiles/tile"
var dark_color = Color(.18, .20, .22, 1)
var theme   ;  var theme_data    #info about tiles
#var tween_ID ; var tween_calls
var texture_list
var def_pos ; var def_rot ; var def_sca




func _ready():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
#	yield(get_tree().create_timer(.001), "timeout")
#	$Sprite.modulate = dark_color

	$Sprite.flip_v = true if randf() > .5 else false
	$Sprite.flip_h = true if randf() > .5 else false

	yield(get_tree().create_timer(.004), "timeout")
	theme      = G.SETTINGS.theme
	theme_data = $"../../".theme_data[theme]

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

	position = G.gen_offscreen_pos(120)
	rotation_degrees = randi() % 361
	var a = rand_range(.2, 2.2)
	scale = Vector2(a, a)

	# START ANIMS:
	tween.set_parallel(true)
	tween.tween_property($".", "position", def_pos, rand_range(.32, .64)
		).set_ease(Tween.EASE_IN)

	tween.tween_property($".", "rotation_degrees", def_rot, rand_range(.46, .82)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property($".", "scale", def_sca, .6
		).set_ease(Tween.EASE_OUT)

	tween.tween_interval(.64)
	tween.set_parallel(false)
	tween.tween_property($".", "scale", def_sca * .4, .6
		).set_ease(Tween.EASE_IN)

	tween.tween_property($".", "scale", def_sca, .8
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)
	tween.tween_callback($".", "board_finish")






func board_finish():
	$"../".allow_board_input = true

	if theme_data[2] == false:
		$Sprite.modulate = dark_color
	else:
		$Sprite.texture = load(path + str(theme) + "_OFF.png")






func reveal():
	if theme_data[2] == false:
		$Sprite.modulate = Color(1,1,1,1)
	else:
		$Sprite.texture = load(path + str(theme) + "_ON.png")






func _on_Area2D_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	$"../".check_clicked_tile()
