extends Camera2D


export var zoom_step  := 0.2
export var max_zoom   := 2
export var min_zoom   := 0.6


var target_zoom          := Vector2.ZERO
var is_dragging          := false
var drag_start_position  := Vector2.ZERO

#var cam_min_coord        := Vector2.ZERO
var cam_max_coord        :  int






func _ready():
	yield(get_tree().create_timer(.004), "timeout")
	cam_max_coord  = ($"../".board_size.y * $"../".tile_size) / 2.225
	var i          = G.SETTINGS.zoom_level
	target_zoom    = Vector2(i, i)

#	set_process(true)






func _process(delta: float):
	#camera zoom
	if zoom != target_zoom:
		var i        = clamp(target_zoom.x, min_zoom, max_zoom)
		target_zoom  = Vector2(i,i)
		zoom         = lerp(zoom, target_zoom, zoom_step * 20 * delta)

	#drag limits
	var cam_pos  = position
	cam_pos.x    = clamp(cam_pos.x, -cam_max_coord+G.window.x/2, cam_max_coord++G.window.x/2)
	cam_pos.y    = clamp(cam_pos.y, -cam_max_coord+G.window.y/2, cam_max_coord++G.window.y/2)
	position     = cam_pos






func _input(event: InputEvent):
	if event.is_pressed():
		if event.is_action_pressed("zoom+"):
			target_zoom += Vector2(zoom_step, zoom_step)
		elif event.is_action_pressed("zoom-"):
			target_zoom -= Vector2(zoom_step, zoom_step)


	#dragging
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				is_dragging          = true
				drag_start_position  = event.position
			else:
				is_dragging = false
	elif event is InputEventMouseMotion:
		if is_dragging:
			var drag_end_position = event.position
			var drag_vector = drag_end_position - drag_start_position
			drag_vector *= -1
			drag_vector /= zoom.x * 16
			global_position += drag_vector
#			print(position)  #prints cam position

	G.SETTINGS.zoom_level  = target_zoom.x

	#sent zoom info
	get_parent().get_node("BG").parr(target_zoom.x)
