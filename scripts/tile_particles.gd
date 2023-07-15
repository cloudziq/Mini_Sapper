extends Node2D




func _ready():
	z_index  = 2
#	$Particles_blink.scale     = Vector2(1.6, 1.6)
	$Particles_blink.one_shot  = true
	$Particles_small.one_shot  = true
	$Particles_blink.visible   = false
	$Particles_small.visible   = true




#func show(type := false):
##	$Particles_blink.visible      = true
#	if type:
#		$Particles_small.visible  = true
