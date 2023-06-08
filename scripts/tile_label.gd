extends CenterContainer


onready var label        = $"Label"




func _ready():
	visible        = false
	rect_scale     = Vector2(2, 2)
	rect_rotation  = 0
#
#
#
#func reveal_label(tile_rotation):
#	show()
#	tile_rotation = rad2deg(tile_rotation)
#	if tile_rotation < 0:
#		$Label.rect_rotation = 0 + tile_rotation
#	else:
#		$Label.rect_rotation = 0 - tile_rotation




func reveal(tile_rotation):
	var tween      = get_tree().create_tween()
	var def_sca    = rect_scale * .6
	rect_scale     = Vector2(.02, .02)
	rect_rotation  = 0 - abs(tile_rotation) + rand_range(- 12, 12)
	visible        = true

#	print(def_sca)
	tween.tween_property($".", "rect_scale", def_sca , rand_range(1.2, 1.8)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
