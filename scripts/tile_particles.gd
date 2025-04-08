extends Node2D


onready var tween : SceneTreeTween






func _ready() -> void:
	$particles_small.one_shot   = true
	$particles_blink.one_shot   = true
	$particles_helper.one_shot  = true
	$particles_small.emitting   = false
	$particles_blink.emitting   = false
	$particles_helper.emitting  = false






func delay(delay:float):
	tween  = get_tree().create_tween()
	tween.tween_callback(self, "fade").set_delay(delay)






func fade() -> void:
	tween  = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, .4)
	tween.tween_callback(self, "queue_free")






#func hide() ->void:
#	get_tree().call_group("particles_move", "visible", [false])
#	self.visible  = false
#	self.visible  = false
