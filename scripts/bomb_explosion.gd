extends Node2D


var max_shape_radius



func _ready():
	max_shape_radius = $bomb_wave/collision.shape.radius
	$bomb_wave/collision.shape.radius = .82
	$Tween.interpolate_property($bomb_wave/collision.shape, "radius",
		1, max_shape_radius, .26,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

	$fire.one_shot = true
	$blink.one_shot = true
	$smoke.one_shot = true
