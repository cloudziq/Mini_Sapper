extends Sprite


var anim_dir  := 1
var scale_def := Vector2(.88, .88)






func _ready():
	scale      = scale_def
	modulate   = Color(.28, 1.2, .44, .84)
	yield(get_tree().create_timer(.01), "timeout")
	anim_dir = 1 ; marker_anim()






func color_tint(type):
	match type:
		"correct":    self.modulate  = Color(0.4, 1.20, .45, .8)
		"incorrect":  self.modulate  = Color(1.2, 0.22, .20, .8)






func marker_anim():
	var scale_to

	if anim_dir == 1:
		scale_to = Vector2(1.28, 1.28)
		anim_dir = -1
	else:
		scale_to = scale_def
		anim_dir = 1

	$Tweenie.interpolate_property($".", "scale",
		$".".scale, scale_to, .8,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tweenie.start()
