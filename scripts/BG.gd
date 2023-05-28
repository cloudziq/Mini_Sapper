extends Node2D


var BG_amount = 64
onready var _ball = preload("res://scenes/BG/BG_object.tscn")



func _ready():
	randomize()
	spawn_ball()
	change_BG_scroll(true)
	var path = "res://assets/graphics/level_bg/OLD/bg"
	var num  = str(floor(rand_range(1, BG_amount)))
	$CanvasLayer/BG2.texture = load(path+num+".png")
	$CanvasLayer/BG3.texture = load(path+num+".png")




func _process(delta: float):
	$CanvasLayer/BG.rotate(  .040 * delta)
	$CanvasLayer/BG2.rotate(-.044 * delta)
	$CanvasLayer/BG3.rotate(-.052 * delta)






func _input(event: InputEvent):
	if event.is_action_pressed("reload_BG"):
		var _i = get_tree().reload_current_scene()






func spawn_ball():
	var window = get_viewport_rect().size
	var offset = 40

	for i in 12:
		var x       = rand_range(offset, window.x - offset)
		var y       = rand_range(offset, window.y - offset)
		var ball = _ball.instance()

		ball.position                           = Vector2(x, y)
		ball.linear_velocity.x                  = rand_range(  -6,  6)
		ball.linear_velocity.y                  = rand_range( -20, 20)
		ball.angular_velocity                   = rand_range( -.1, .1)
		var r = rand_range(0.1, .2)
		var g = rand_range(.1, 2)
		var b = rand_range(.2, 4)
#		var s = rand_range(32, 88)

		ball.modulate = Color(r,g,b, .64)
#		var node = ball.get_node("CollisionShape2D/Sprite")
#		ball.get_node("CollisionShape2D")       .scale = Vector2(.02, .02)
#		ball.get_node("CollisionShape2D/Sprite").scale = Vector2(s,s)

		$CanvasLayer.add_child(ball)
#		print("ball added at: " + str(Vector2(x, y)))






func change_BG_scroll(init: bool = false):
	var mat : ShaderMaterial = $CanvasLayer/BG.material

	if init:
		mat.set_shader_param("x_scroll", 120)
		mat.set_shader_param("y_scroll", 80)
	else:    #?? wyjebać czy nie
		var x_scroll = rand_range(-60, 60)
		var y_scroll = rand_range(-20, 60)
		mat.set_shader_param("x_scroll", x_scroll)
		mat.set_shader_param("y_scroll", y_scroll)
