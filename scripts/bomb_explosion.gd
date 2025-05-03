extends Node2D


var path  = "res://assets/sounds/explode/"




func _ready() -> void:
	$explosion.stream  = load(path+"explode"+str(randi()%2+1)+".ogg")
	$explosion.pitch_scale  = randf_range(.32, .8)
	$explosion.play()

#	var rot  := rand_range(0,360)
#	$Sprite1.rotation_degrees  = rot
#	$Sprite2.rotation_degrees  = rot

	$AnimationPlayer.play("explode")

	get_tree().call_group("tile", "tile_blast_motion", position)

	await get_tree().create_timer(6).timeout
	queue_free()
