extends Node2D


var t  :  SceneTreeTween




func _ready():
	z_index  = 1
	$particles_small.one_shot  = true
	$particles_blink.one_shot  = true
	$particles_small.emitting  = false
	$particles_blink.emitting  = false

	var node  = $particles_blink

	t  = self.create_tween()
	t.tween_callback(self, "fade").set_delay(node.lifetime + node.preprocess)




func fade() -> void:
	if t:  t.kill()
	t  = self.create_tween()
	t.tween_property(self, "modulate", Color(1,1,1,0), 1)
	t.tween_callback(self, "queue_free")
