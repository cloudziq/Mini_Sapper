extends CenterContainer


var def_sca    := rect_scale * .92
var def_rot    := 0
var skew_dist  := 16






func _ready():
	visible        = false






func reveal(tile_rotation):
	var tween      := get_tree().create_tween()
	def_rot        = 0 - abs(tile_rotation) + rand_range(-skew_dist, skew_dist)
	rect_rotation  = def_rot
	rect_scale     = Vector2(.02, .02)
	visible        = true

	#reveal label anim:
	tween.set_parallel(false)
	tween.tween_property($".", "rect_scale", def_sca , rand_range(.8, 1.4)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(self, "animate_label").set_delay(0.2)
#	animate_label()






func animate_label():
	var tween      = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var rot        = def_rot

	rot += rand_range(-skew_dist, skew_dist)

	tween.set_parallel(false)
	tween.tween_property($".", "rect_rotation", rot, rand_range(2, 4)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(self, "animate_label").set_delay(0.1)
