extends Node2D




func _ready():
	$Sprite.self_modulate     = Color(4,4,4,1)
	$Sprite.rotation_degrees  = rand_range(0, 360)
	$Sprite.scale             = Vector2(.1, .1)
	$Sprite.z_index           = 1000
	$Sprite2.z_index          = 1
	global_position           = $"../".crack_pos




func fade():
	$anim_color.interpolate_property($Sprite, "scale",
		$Sprite.scale, $Sprite.scale * 12, .22,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$anim_color.interpolate_property($Sprite, "self_modulate",
		$Sprite.self_modulate, Color(1,1,1,0), 5,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, 2.8)

	$anim_color.interpolate_property($Sprite2, "self_modulate",
		$Sprite2.self_modulate, Color(1,1,1,0), 2.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.6)
	$anim_color.start()



func _on_anim_color_completed():
	queue_free()
