extends Node2D


var max_blast_range := 400




func _ready() -> void:
#	max_blast_range                    = $bomb_wave/collision.shape.radius * 2
#	$bomb_wave/collision.shape.radius  = .01

	$fires.one_shot  = true
	$blink.one_shot  = true
	$smoke.one_shot  = true



#	tween.tween_property($bomb_wave/collision.shape, "radius", max_blast_range, .6)
	for i in get_tree().get_nodes_in_group("tile"):
		i.tile_blast()

#	yield(get_tree().create_timer(3), "timeout")
#	finish()




#func finish() -> void:
#	for i in get_tree().get_nodes_in_group("tile"):
#		i.queue_free()

	yield(get_tree().create_timer(3), "timeout")
	queue_free()
