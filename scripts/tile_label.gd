extends CenterContainer


var rot       :  float
var def_sca   := scale
var skew_dist := 16






func _ready() -> void:
	visible    = false






func animate_label() -> void:
	var tween  = self.create_tween()

	rot  = -get_parent().rotation_degrees
	rot += randf_range(-skew_dist, skew_dist)

	tween.tween_property(self, "rotation", rot, randf_range(1.2, 2.0)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

#	if get_parent().allow_idle_anim:
	tween.tween_callback(Callable(self, "animate_label")).set_delay(0.2)






func reveal() -> void:
	var tween      = self.create_tween()

	rot            = -get_parent().rotation_degrees +randf_range(-skew_dist *4, skew_dist *4)
	scale     = Vector2(.006, .00)
	rotation  = rot
	visible        = true

	tween.tween_property(self, "scale", def_sca , randf_range(.8, 1.4)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_callback(Callable(self, "animate_label")).set_delay(0.2)
