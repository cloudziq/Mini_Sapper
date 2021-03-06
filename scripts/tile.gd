extends Area2D


var dark_color = Color(.18, .20, .22, 1)
var theme_data ; var settings
var tween_ID ; var tween_calls
var path = "res://assets/graphics/tiles/tile"
var texture_list
var def_pos ; var def_rot ; var def_sca




func _ready():
#	yield(get_tree().create_timer(.001), "timeout")

	$Sprite.flip_v = true if randf() > .5 else false
	$Sprite.flip_h = true if randf() > .5 else false

	yield(get_tree().create_timer(.001), "timeout")
	theme_data = get_node("../../").theme_data
	settings = get_node("../../").SETTINGS

	if theme_data[settings.theme][0] == 1:
		if theme_data[settings.theme][2] == false:
			$Sprite.texture = load(path + str(settings.theme + 1) + ".png")
		else:
			$Sprite.texture = load(path + str(settings.theme + 1) + "_ON.png")
	else:
		var num = randi() % theme_data[settings.theme][0] + 1
		$Sprite.texture = load(path + str(settings.theme + 1) +"_"+ str(num) + ".png")

	if theme_data[settings.theme][1] == 1:
		rotation_degrees = 90 if randf() > .5 else 0
	else:
		rotation_degrees = rand_range(0, 360)

	#### START LEVEL TILES ANIMATION:
	def_pos = position
	def_rot = rotation_degrees
	def_sca = scale

	position = $"../../".gen_offscreen_pos(100)
	rotation_degrees = randi() % 361
	var a = rand_range(.2, 6.2)
	scale = Vector2(a, a)

#	yield(get_tree().create_timer(.1), "timeout")
	$Tween.interpolate_property($".", "position",
		position, def_pos, rand_range(.6, 1.2),
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.interpolate_property($".", "rotation_degrees",
		rotation_degrees, def_rot, 1,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween_ID    = "on begin" ; tween_calls = 2
	$Tween.interpolate_property($".", "scale",
		scale, def_sca, .6,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.start()








func _on_Area2D_area_shape_entered(area_rid, _area, _area_shape_index, _local_shape_index):
	$"../".check_clicked_tile()




func _on_tween_completed(object, key):
	if key == ":scale" and tween_calls > 0:
		match tween_calls:
			2:
				$Tween.interpolate_property($".", "scale",
					scale, def_sca * .5, .6,
					Tween.TRANS_QUINT, Tween.EASE_IN)
			1:
				$Tween.interpolate_property($".", "scale",
					scale, def_sca, randi() % 8 + 1,
					Tween.TRANS_QUINT, Tween.EASE_OUT)

		tween_calls -= 1
	$Tween.start()
