extends Area2D


var path = "res://assets/graphics/tiles/tile"
var dark_color = Color(.18, .20, .22, 1)
var theme   ;  var theme_data    #info about tiles
var tween_ID ; var tween_calls
var texture_list
var def_pos ; var def_rot ; var def_sca




func _ready():
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

	position = $"../../".gen_offscreen_pos(120)
	rotation_degrees = randi() % 361
	var a = rand_range(.2, 6.2)
	scale = Vector2(a, a)

#	yield(get_tree().create_timer(.1), "timeout")
	$Tween.interpolate_property($".", "position",
		position, def_pos, rand_range(.36, .64),
		Tween.TRANS_QUINT, Tween.EASE_IN)
	$Tween.interpolate_property($".", "rotation_degrees",
		rotation_degrees, def_rot, .85,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween_ID    = "on begin" ; tween_calls = 2
	$Tween.interpolate_property($".", "scale",
		scale, def_sca, .6,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
#
#	$Tween.interpolate_property($Sprite, "modulate",
#		position, def_pos, rand_range(.6, 1.2),
#		Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.start()







func _on_Area2D_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	$"../".check_clicked_tile()




func _on_tween_completed(_object, key):
	if key == ":scale" and tween_calls > 0:
		match tween_calls:
			2:
				$Tween.interpolate_property($".", "scale",
					scale, def_sca * .5, .4,
					Tween.TRANS_QUINT, Tween.EASE_IN)
			1:
				$Tween.interpolate_property($".", "scale",
					scale, def_sca, randi() % 1 + 1,
					Tween.TRANS_ELASTIC, Tween.EASE_OUT)
				$Tween.interpolate_property($Sprite, "modulate",
					modulate, dark_color, .8,
					Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween_calls -= 1
	$Tween.start()




func _input(event: InputEvent):
	if event.is_action_pressed("change_tile"):
		G.SETTINGS.theme  = int(floor(rand_range(1, $"../../".BG_amount)))
		G.save_config()
		_ready()
