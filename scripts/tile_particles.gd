extends Node2D




func _ready():
	z_index = 3
	$Particles_blink.scale = Vector2(1.6, 1.6)
	$Particles_blink.one_shot = true
	$Particles_small.one_shot = true
