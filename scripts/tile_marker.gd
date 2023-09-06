extends Sprite


var t_sca          :  SceneTreeTween
var game_over_tint :  bool
var scale_def      := scale






func _ready()  -> void:
	modulate          = Color(.4, 2, 1, 1)
	rotation_degrees  = rand_range(0, 360)
	marker_anim()






# true=correct, false=incorrect
func color_tint() -> void:
	match game_over_tint:
		true  : self.modulate  = Color(.2,  2, .2, 1)
		false : self.modulate  = Color( 2, .1, .1, 1)






func marker_anim(dir := false) -> void:
	var scale_to : Vector2
	dir  = not dir

	if dir:
		scale_to  = scale_def * 1.22
	else:
		scale_to  = scale_def

	t_sca = self.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t_sca.tween_property(self, "scale", scale_to, .8).set_delay(.1)
	t_sca.tween_callback(self, "marker_anim", [dir]).set_delay(.1)






func remove() -> void:
	var sca  = scale_def
	sca.x    = sca.x * 12
	sca.y    = sca.y * 3

	var col  = modulate
	col.a    = 0

	if t_sca:  t_sca.kill()

	t_sca = self.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t_sca.tween_property(           self, "scale",    sca,  1)
	t_sca.parallel().tween_property(self, "modulate", col, .9).set_trans(Tween.TRANS_LINEAR)
	t_sca.tween_callback(           self, "queue_free").set_delay(.1)
