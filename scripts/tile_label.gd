extends CenterContainer


var def_sca    := rect_scale
var def_rot    := 0.0
var skew_dist  := 16






func _ready():
	visible        = false






func animate_label():
	var tween  = get_tree().create_tween()
	var rot    = 0 - abs($"../".rotation_degrees)

	rot +=  rand_range(-skew_dist, skew_dist)

	tween.tween_property(self, "rect_rotation", rot, rand_range(1, 3)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(self, "animate_label").set_delay(0.1)






func reveal(rot := 0):
	def_rot        = 0 - abs(rot) + rand_range(-skew_dist, skew_dist)
	rect_scale     = Vector2(.01, .01)
	rect_rotation  = def_rot
	visible        = true
	var tween      = get_tree().create_tween()

	tween.tween_property(self, "rect_scale", def_sca , rand_range(.8, 1.4)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_callback(self, "animate_label").set_delay(0.2)
