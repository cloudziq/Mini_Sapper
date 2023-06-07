extends Node2D

onready var _ball      = preload("res://scenes/BG/BG_object.tscn")

onready var BG_amount  = $"../../".BG_amount






func _ready():
	var path ; var num : String ; var node ; var scale ; var val
	var scale_mult  := 3.2
	randomize()

	spawn_ball()

	# BG's init:
	path   = "res://assets/graphics/level_bg/OLD/BG_"

	node   = $CanvasLayer/BG2_mix
	num    = str(floor(rand_range(1, BG_amount)))
	scale  = node.scale
	val    = rand_range(scale.x, scale.y * scale_mult)
	node.texture  = load(path+num+".png")
	node.scale    = Vector2(val, val)

	node  = $CanvasLayer/BG3_detail
	num   = str(floor(rand_range(1, BG_amount)))
	scale  = node.scale
	val    = rand_range(scale.x, scale.x * scale_mult)
	node.texture = load(path+num+".png")
	node.scale    = Vector2(val, val)






func _process(dt: float):
	$CanvasLayer/BG_main.rotate   ( .022 * dt)
	$CanvasLayer/BG2_mix.rotate   (-.016 * dt)
	$CanvasLayer/BG3_detail.rotate(-.018 * dt)






func _input(event: InputEvent):
	if event.is_action_pressed("reload_BG"):
		var _i = get_tree().reload_current_scene()
	elif event.is_action_pressed("change_tile"):
		G.SETTINGS.theme  = int(floor(rand_range(1, $"../../".theme_data.size())))
		G.save_config()
		var _i = get_tree().reload_current_scene()






func spawn_ball():
	var window = get_viewport_rect().size
	var offset = 40

	for i in 8:
		var x       = rand_range(offset, window.x - offset)
		var y       = rand_range(offset, window.y - offset)
		var ball = _ball.instance()

		ball.position                           = Vector2(x, y)
		ball.linear_velocity.x                  = rand_range( -10, 10)
		ball.linear_velocity.y                  = rand_range( -40, 40)
		ball.angular_velocity                   = rand_range( -.1, .1)
		var r = rand_range(.1, .4)
		var g = rand_range(.2, .8)
		var b = rand_range(.3,  1)

		var s1 = rand_range(2.2, 4)
		var s2 = rand_range(2.6, 6)

		ball.modulate = Color(r,g,b, .82)
#			var node = ball.get_node("CollisionShape2D/Sprite")
#			ball.get_node("CollisionShape2D")       .scale = Vector2(.02, .02)
		ball.get_node("CollisionShape2D/Sprite").scale = Vector2(s1, s2)

		$CanvasLayer.add_child(ball)
#			print("ball added at: " + str(Vector2(x, y)))






#func change_BG_scroll(init: bool = false):
#	var mat : ShaderMaterial = $CanvasLayer/BG.material
#
#	if init:
#		mat.set_shader_param("x_scroll", 120)
#		mat.set_shader_param("y_scroll", 80)
#	else:    #?? wyjebać czy nie
#		var x_scroll = rand_range(-60, 60)
#		var y_scroll = rand_range(-20, 60)
#		mat.set_shader_param("x_scroll", x_scroll)
#		mat.set_shader_param("y_scroll", y_scroll)
