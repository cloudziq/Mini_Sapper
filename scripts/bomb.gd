extends Sprite




func _ready():
	scale = Vector2(.85, .85)
	z_index = 1




func reveal_bomb(tile_rotation):
	var rot = tile_rotation
	if rot < 0:
		rotation = 0 + rot
	else:
		rotation = 0 - rot
