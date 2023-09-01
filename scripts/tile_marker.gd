extends Sprite

var t_sca     :  SceneTreeTween

var scale_def := scale






func _ready()  -> void:
	z_index           = 1
	modulate          = Color(.4, 2, 1, 1)
	rotation_degrees  = rand_range(0, 360)
	marker_anim()





# 0=correct, 1=incorrect
func color_tint(type : int) -> void:
	match type:
		0 : self.modulate  = Color(0.4, 1.20, .45, .8)
		1 : self.modulate  = Color(1.2, 0.22, .20, .8)






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
