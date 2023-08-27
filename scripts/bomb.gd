extends Sprite


var pos : Vector2


onready var def_sca : Vector2  = scale






func _ready():
	visible  = false
#	z_index  = 1






func reveal_bomb(tile_rotation):
	visible   = true
	rotation  = 0 - abs(tile_rotation)






func bomb_anim() -> void:
	var t_sca  = get_tree().create_tween().set_loops()
	var t_col  = get_tree().create_tween().set_loops()

	t_sca.tween_property(self, "scale", def_sca * 1.6, .1).set_delay(.06)
	t_sca.tween_property(self, "scale", def_sca * 0.8, .1).set_delay(.06)

	t_col.tween_property(self, "modulate", Color(4, 1, 1, 1), .1)
	t_col.tween_property(self, "modulate", Color(1, 1, 1, 1), .1)

	new_shake_pos()






func new_shake_pos() -> void:
	var t_pos  = get_tree().create_tween()

	pos = Vector2.ZERO
	pos.x += rand_range(-6, 6)
	pos.y += rand_range(-6, 6)

	t_pos.tween_property(self, "position", pos, .2).set_delay(.01)
	t_pos.tween_callback(self, "new_shake_pos")

