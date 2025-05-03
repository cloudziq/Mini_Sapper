extends Node2D


var screen_w ; var screen_h
var is_vertical : int = 0

var CHANGE = true




func _ready():
	screen_w = get_viewport().size.x
	screen_h = get_viewport().size.y

	await get_tree().create_timer(.012).timeout    # why

	if is_vertical:
		$Light3D.rotation_degrees = 90
		$Light3D.scale = Vector2(4, 6)
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
			position_y = randf_range(0, screen_h)
			time = randf_range(8, 16)
		else:
			pos_mod = (screen_h / 6)
			pos_mod = pos_mod if randi() % 2 + 1 == 1 else -pos_mod
			position_x = randf_range(0, screen_w)
			position_y = (screen_h / 2) + pos_mod
			time = randf_range(10, 20)

		$light_pos.interpolate_property($Light3D, "position",
			$Light3D.position, Vector2(position_x, position_y), time * 0.92,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, randf_range(.8, 2.2))
		$light_pos.start()

		var new_r = randf_range(.12, .84)
		var new_g = randf_range(.24, .62)
		var new_b = randf_range(.32, .66)
		$light_col.interpolate_property($Light3D, "color",
			$Light3D.color, Color(new_r, new_g, new_b, randf_range(.24, .62)), time,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT, randf_range(.8, 2.2))
		$light_col.start()

		CHANGE = false




func _on_light_pos_end():
	CHANGE = true


func _on_light_height_end():
	$light_height.interpolate_property($Light3D, "range_height",
		$Light3D.range_height, randf_range(38, 92), randf_range(16, 50),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, randf_range(4, 16))
	$light_height.start()


func _on_light_energy_end():
	$light_energy.interpolate_property($Light3D, "energy",
		$Light3D.energy, randf_range(1.8, 6), randf_range(10, 20),
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, randf_range(4, 10))
	$light_energy.start()
