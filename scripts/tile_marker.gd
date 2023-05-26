extends Sprite


var anim_dir ; var scale_def




func _ready():
	scale_def = Vector2(.88, .88) ; scale = scale_def
	modulate = Color(.28, 1.2, .44, .84)
	yield(get_tree().create_timer(.01), "timeout")
	anim_dir = 1 ; marker_anim()
	z_index = 2




func color_tint(type):
	match type:
		"correct":   $".".modulate = Color(.4, 1.2, .45, .8)
		"incorrect": $".".modulate = Color(1.2, .22, .2, .8)




func marker_anim():
	var scale_to

	if anim_dir == 1:
		scale_to = Vector2(1.28, 1.28)
		anim_dir = -1
	else:
		scale_to = scale_def
		anim_dir = 1

	$Tween.interpolate_property($".", "scale",
		$".".scale, scale_to, .8,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
