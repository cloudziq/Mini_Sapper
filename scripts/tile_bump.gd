extends Node2D


onready var def_sca  :  Vector2  = get_parent().def_sca
onready var def_col  :  Color    = get_parent().def_col
onready var rot      := 0.0
onready var ttl      := 6

var t : SceneTreeTween




func _ready() -> void:
	t   = self.create_tween()

	var i      : float
	i  = rand_range(-.04, .02)
	var s_min  : Vector2  = def_sca * 3.6 + Vector2(i, i)
	i  = rand_range(-.02, .06)
	var s_max  : Vector2  = def_sca * 4.16 + Vector2(i, i)

	var col  = def_col
	col.r   *= 8
	col.g   *= 4.4
	col.b   *= .4

	$Sprite.texture  = get_parent().get_node("Sprite").texture


	t.tween_property(self, "scale", s_min, .16 + rand_range(-.02, .04)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	t.tween_property(self, "scale", s_max, .22 + rand_range(-.04, .04)
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(.06)

	t.parallel().tween_property($Sprite, "modulate", col,
		.36 + rand_range(-.04, .04)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)

	i  = rand_range(.12, .24)
	t.tween_property(self, "scale", def_sca * 4 + Vector2(i, i),
		.64 + rand_range(-.06, .06)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(.06)

	rot += rand_range(-6, 6)
	t.parallel().tween_property(self, "rotation_degrees", rot,
		.52 + rand_range(-.08, .08)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	i  = rand_range(.06, .08)
	t.tween_property(self, "scale", def_sca * 4 + Vector2(i, i),
		2 + rand_range(-.1, .1)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.1)


	#back to default:
	def_col.a  = 0
	t.parallel().tween_property($Sprite, "modulate", def_col,
		ttl + rand_range(-ttl * .14 , ttl * .12)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)

	t.tween_callback(self, "queue_free")
