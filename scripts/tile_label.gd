extends Node2D




func _ready():
	z_index = 2
	hide()




func reveal_label(tile_rotation):
	show()
	tile_rotation = rad2deg(tile_rotation)
	if tile_rotation < 0:
		$Label.rect_rotation = 0 + tile_rotation
	else:
		$Label.rect_rotation = 0 - tile_rotation
