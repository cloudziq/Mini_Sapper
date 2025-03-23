extends Node2D


var path  = "res://assets/sounds/explode/"




func _ready() -> void:
	$explosion.stream  = load(path+"explode"+str(randi()%2+1)+".ogg")
	$explosion.play()

	$explosion.pitch_scale  = rand_range(.32, .8)
	$AnimationPlayer.play("explode")

	for i in get_tree().get_nodes_in_group("tile"):
		i.tile_blast(position)

	yield(get_tree().create_timer(3), "timeout")
	queue_free()
