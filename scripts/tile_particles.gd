extends Node2D




func _ready():
	z_index  = 1
	$particles_small.emitting    = false
	$particles_blink.emitting    = false





func smooth_remove(time:float) -> void:
	var t  = self.create_tween().set_parallel()

	t.tween_property($particles_small, "modulate", Color(1,1,1,0), time)
	t.tween_property($particles_blink, "modulate", Color(1,1,1,0), time)
#	t.chain().tween_callback(self, "queue_free").set_delay(time)
