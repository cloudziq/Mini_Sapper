extends Camera2D


export var zoom_step  := 0.2
export var max_zoom   := 1.4
export var min_zoom   := 0.5


var target_zoom          := Vector2.ZERO
var drag_start_position  := Vector2.ZERO
var drag_vector          := Vector2.ZERO
var cam_limit_coords     := Vector2.ZERO
var new_pos              := position
var is_dragging          := false
var is_moving            := false






func _ready():
	var i  = G.SETTINGS.zoom_level

	yield(get_tree().create_timer(.04), "timeout")
	cam_limit_coords  = ($"../".board_size * $"../".tile_size) / 2.225
	target_zoom       = Vector2(i, i)

#	get_parent().get_node("BG").parr(target_zoom.x, .4)





func _process(delta: float) -> void:
	#camera zoom
	if zoom != target_zoom:
		var i        = clamp(target_zoom.x, min_zoom, max_zoom)
		target_zoom  = Vector2(i,i)
		zoom         = lerp(zoom, target_zoom, zoom_step * 20 * delta)

		#send zoom info to BG parallax effect:
		get_parent().get_node("BG").parr(target_zoom.x)

	#drag limits
#	new_pos  = position + drag_vector
	var x1       = -cam_limit_coords.x + G.window.x/2
	var x2       = cam_limit_coords.x + G.window.x/2
	var y1       = -cam_limit_coords.y + G.window.y/2
	var y2       = cam_limit_coords.y + G.window.y/2

	new_pos.x    = clamp(new_pos.x, x1, x2)
	new_pos.y    = clamp(new_pos.y, y1, y2)

	if position.snapped(Vector2(1,1)) != new_pos.snapped(Vector2(1,1)):
		position   = position.linear_interpolate(new_pos, 10 * delta)
		is_moving  = false






func _input(event: InputEvent) -> void:
	#cam zooming:
	if event.is_pressed():
		if event.is_action_pressed("zoom+"):
			target_zoom += Vector2(zoom_step, zoom_step)
		elif event.is_action_pressed("zoom-"):
			target_zoom -= Vector2(zoom_step, zoom_step)

		G.SETTINGS.zoom_level  = target_zoom.x


	#cam dragging:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_dragging          = true
			drag_start_position  = event.position
		else:
			is_dragging          = false

	elif event is InputEventMouseMotion and is_dragging:
		drag_vector    = (event.position - drag_start_position) * -1
		drag_vector   *= zoom.x * .28
		new_pos        = position + drag_vector

		var drag_dist  = drag_vector.x + drag_vector.y
		drag_vector    = Vector2.ZERO

		if drag_dist >= 2 or drag_dist <= -2:
			is_moving  = true
		else:
			is_moving  = false
