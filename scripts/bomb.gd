extends Sprite


export(PackedScene) var _explosion  ;  var EXPLOSION : Node2D


onready var def_sca : Vector2  = scale

var rot       :  float
var skew_dist := 16





func _ready() -> void:
	visible  = false






func reveal_bomb() -> void:
	visible  = true
	animate_pos()






func animate_pos() -> void:
	var tween  = self.create_tween()

	rot  = -get_parent().rotation_degrees
	rot += rand_range(-skew_dist, skew_dist)

	tween.tween_property(self, "rotation_degrees", rot, rand_range(.8, 1.2)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

#	if get_parent().allow_idle_anim:
	tween.tween_callback(self, "animate_pos").set_delay(0.2)






func bomb_anim() -> void:    # animates a bomb which was clicked (ready to blow)
	var t_sca  = self.create_tween().set_loops()
	var t_col  = self.create_tween().set_loops()

	t_sca.tween_property(self, "scale", def_sca * 1.6, .1).set_delay(.06)
	t_sca.tween_property(self, "scale", def_sca * 0.8, .1).set_delay(.06)

	t_col.tween_property(self, "modulate", Color(4, 1, 1, 1), .1)
	t_col.tween_property(self, "modulate", Color(1, 1, 1, 1), .1)

	new_shake_pos()






func new_shake_pos() -> void:
	var pos := Vector2.ZERO
	pos.x += rand_range(-6, 6)
	pos.y += rand_range(-6, 6)

	var t_pos  = self.create_tween()

	t_pos.tween_property(self, "position", pos, .2).set_delay(.01)
	t_pos.tween_callback(self, "new_shake_pos")






func explosion_visuals() -> void:
	EXPLOSION  = _explosion.instance()
	EXPLOSION.position  = get_parent().position
	$"../../".add_child(EXPLOSION)
	get_parent().get_node("%Sprite").visible  = false
	get_tree().call_group("bomb", "visible", [false])
