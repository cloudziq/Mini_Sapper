extends Node2D


var screen_w ; var screen_h
var is_vertical : int = 0

var CHANGE = true




func _ready():
	screen_w = get_viewport().size.x
	screen_h = get_viewport().size.y

	yield(get_tree().create_timer(.012), "timeout")    # why

	if is_vertical:
		$Light.rotation_degrees = 90
		$Light.scale = Vector2(4, 6)
	$light_height.start()
	$light_energy.start()




func _process(_dt):
	var position_x
	var position_y
	var time
	var pos_mod

	if CHANGE:
		if is_vertical:
			pos_mod = (screen_w / 4)
			pos_mod = pos_mod if randi() % 2 + 1 == 1 else -pos_mod
			position_x = (screen_w / 2) + pos_mod
			position_y = rand_range(0, screen_h)
			time = rand_range(8, 16)
		else:
			pos_mod = (screen_h / 6)
			pos_mod = pos_mod if randi() % 2 + 1 == 1 else -pos_mod
			position_x = rand_range(0, screen_w)
			position_y = (screen_h / 2) + pos_mod
			time = rand_range(10, 20)

		$light_pos.interpolate_property($Light, "position",
			$Light.position, Vector2(position_x, position_y), time * 0.92,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(.8, 2.2))
		$light_pos.start()

		var new_r = rand_range(.12, .84)
		var new_g = rand_range(.24, .62)
		var new_b = rand_range(.32, .66)
		$light_col.interpolate_property($Light, "color",
			$Light.color, Color(new_r, new_g, new_b, rand_range(.24, .62)), time,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(.8, 2.2))
		$light_col.start()

		CHANGE = false




func _on_light_pos_end():
	CHANGE = true


func _on_light_height_end():
	$light_height.interpolate_property($Light, "range_height",
		$Light.range_height, rand_range(38, 92), rand_range(16, 50),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(4, 16))
	$light_height.start()


func _on_light_energy_end():
	$light_energy.interpolate_property($Light, "energy",
		$Light.energy, rand_range(1.8, 6), rand_range(10, 20),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, rand_range(4, 10))
	$light_energy.start()
