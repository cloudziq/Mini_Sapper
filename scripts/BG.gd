extends Node2D


onready var _ball      = preload("res://scenes/BG/BG_object.tscn")
onready var BG_amount  = $"../../".BG_amount






func _ready():
	var path ; var num : String ; var node ; var scale ; var val
	var scale_mult  := 4
	randomize()

	# BG's init:
	spawn_ball()
	path   = "res://assets/graphics/level_bg/OLD/BG_"

	node   = $BG_static/BG2_mix
	num    = str(floor(rand_range(1, BG_amount)))
	scale  = node.scale
	val    = rand_range(scale.x, scale.y * scale_mult)

	node.texture  = load(path+num+".png")
	node.scale    = Vector2(val, val)


	node  = $BG_static/BG3_detail
	num   = str(floor(rand_range(1, BG_amount)))
	scale  = node.scale
	val    = rand_range(scale.x, scale.x * scale_mult)

	node.texture = load(path+num+".png")
	node.scale    = Vector2(val, val)






func _process(dt: float):
	$BG_static/BG_main.rotate   ( .022 * dt)
	$BG_static/BG2_mix.rotate   (-.016 * dt)
	$BG_static/BG3_detail.rotate(-.018 * dt)






func _input(event: InputEvent):
	if $"../".allow_board_input:
		if event.is_action_pressed("reload_BG"):
			var _i  = get_tree().reload_current_scene()
		elif event.is_action_pressed("change_tile"):
			var theme  = int(floor(rand_range(1, $"../../".theme_data.size())))
			print("tile_theme = "  +str(theme))
			G.SETTINGS.theme  = theme
			G.save_config()
			var _i  = get_tree().reload_current_scene()






func spawn_ball():
	yield(get_tree().create_timer(.1), "timeout")
	var offset = 32

	for i in 6:
		var x    := rand_range(offset, G.window.x - offset)
		var y    := rand_range(offset, G.window.y - offset)
		var BALL  = _ball.instance()

		BALL.position           = Vector2(x, y)
		BALL.linear_velocity.x  = rand_range(  -2, 2)
		BALL.linear_velocity.y  = rand_range(  -8, 8)
		BALL.angular_velocity   = rand_range( -.1, .1)
		BALL.get_node("CollisionShape2D/Sprite").texture = $"../".TILE.get_node("Sprite").texture
		var r = rand_range(.2, .3)
		var g = rand_range(.3, .8)
		var b = rand_range(.4,  1)

		var s = rand_range(4.4, 8.6)

		BALL.modulate = Color(r,g,b, .82)
#			var node = ball.get_node("CollisionShape2D/Sprite")
#			ball.get_node("CollisionShape2D")       .scale = Vector2(.02, .02)
		BALL.get_node("CollisionShape2D/Sprite").scale = Vector2(s, s)

		$BG_object.add_child(BALL)
#		add_child(ball)
#			print("object added at: " + str(Vector2(x, y)))






func parr(zoom):
	if zoom > 1:
		var tween  = get_tree().create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property($BG_object, "follow_viewport_scale", 1.2*zoom, .6)
