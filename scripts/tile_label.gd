extends CenterContainer


var def_sca   := rect_scale
var def_rot   := 0.0
var skew_dist := 16






func _ready():
#	visible    = false
	pass






func animate_label():
	var tween  = self.create_tween()
	var rot    = 0 - abs(get_parent().rotation_degrees)

	rot +=  rand_range(-skew_dist, skew_dist)

	tween.tween_property(self, "rect_rotation", rot, rand_range(1, 3)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	if get_parent().allow_idle_anim:
		tween.tween_callback(self, "animate_label").set_delay(0.2)






func reveal(rot := 0):
	var tween      = self.create_tween()
	def_rot        = 0 - abs(rot) + rand_range(-skew_dist, skew_dist)
	rect_scale     = Vector2(.01, .01)
	rect_rotation  = def_rot
	visible        = true

	tween.tween_property(self, "rect_scale", def_sca , rand_range(.8, 1.4)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if get_parent().allow_idle_anim:
		tween.tween_callback(self, "animate_label").set_delay(0.2)
