extends Camera2D


export var zoom_step  := 0.2
export var max_zoom   := 2
export var min_zoom   := 0.6


var target_zoom       : Vector2






func _ready():
	var i        = G.SETTINGS.zoom_level
	target_zoom  = Vector2(i, i)

#	set_process(true)






func _process(delta: float):
	if zoom != target_zoom:
		var i = clamp(target_zoom.x, min_zoom, max_zoom)
		target_zoom = Vector2(i,i)
		zoom = lerp(zoom, target_zoom, zoom_step * 20 * delta)






func _input(event: InputEvent):
	if event.is_pressed():
		if event.is_action_pressed("zoom+"):
			target_zoom += Vector2(zoom_step, zoom_step)
		elif event.is_action_pressed("zoom-"):
			target_zoom -= Vector2(zoom_step, zoom_step)

		G.SETTINGS.zoom_level  = target_zoom.x
		G.save_config()

		get_parent().get_node("BG").parr(zoom)
