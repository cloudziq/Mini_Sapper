extends Sprite




func _ready():
	scale    = Vector2(.85, .85)
	visible  = false
	z_index  = 1




func reveal_bomb(tile_rotation):
	visible   = true
	rotation  = 0 - abs(tile_rotation)
