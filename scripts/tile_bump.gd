extends Node2D


@onready var def_sca  :  Vector2  = get_parent().def_sca
@onready var def_col  :  Color    = get_parent().def_col
@onready var rot      := 0.0
@onready var ttl      := 6

var tween : Tween




func _ready() -> void:
#	if tween: tween.kill()
#	$"%Sprite".material.set_shader_param("fattyness", 2.0)
#	yield(get_tree().create_timer(.1), "timeout")

	tween  = self.create_tween().set_ease(2).set_trans(Tween.TRANS_CIRC).set_parallel(true)

#	i  = rand_range(-.04, .02)
#	var s_min  : Vector2  = def_sca * 3.6 + Vector2(i, i)
	var i := randf_range(-.02, .06)
	var s_max  : Vector2  = def_sca * 5.2 + Vector2(i, i)

	var col : Color  = G.CONFIG.BG_color *G.CONFIG.BG_brightness
	col.a  = .68
	var angle := 32 if randf() >.5 else -32

	$"%Sprite2D".texture  = get_parent().get_node("%Sprite2D").texture


	tween.tween_property(self, "scale", s_max, .22 + randf_range(-.06, .10))
#
#	tween.tween_property(self, "scale", s_max, .12 + rand_range(-.04, .04)
#		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(.06)
	tween.tween_property($"%Sprite2D", "modulate", col, .36 + randf_range(-.04, .04))
	tween.tween_property(self, "rotation_degrees", rotation_degrees +angle, randf_range(.2, .4))
#	tween.tween_property(self, "rotation_degrees", rotation_degrees -180, .4
#		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(.06)

	tween.chain().tween_property(self, "rotation_degrees", rotation_degrees -angle *1.5, .1)

	tween.tween_property(
		$"%Sprite2D", "material:shader_param/fattyness", .6, 4)

	i  = randf_range(.12, .24)
	tween.tween_property(self, "scale", def_sca *4.4 +Vector2(i, i), .08 +randf_range(-.04, .06))

	rot += randf_range(-6, 6)
	tween.tween_property(self, "rotation_degrees", rot,
		.22 + randf_range(-.08, .08))



	#back to default:
#	def_col.a  = 0

	tween.tween_property($"%Sprite2D", "modulate:a", 0,
		ttl + randf_range(-ttl * .14 , ttl * .12)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)

	tween.tween_property(self, "scale", def_sca *4.4, .04)

	tween.chain().tween_callback(Callable(self, "queue_free"))
