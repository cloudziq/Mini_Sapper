extends Node2D


onready var _ball        = preload("res://scenes/BG/BG_object.tscn")
onready var BALL_amount  = $"../../".BALL_amount
onready var BG_amount    = $"../../".BG_amount






func _ready():
	var path  ;  var num : String
	var node  ;  var scale  ;  var val
	var scale_mult  := 4

	randomize()
	spawn_ball()

	# BG1 texture is set in Inspector Tab, uses custom shader

	node   = $BG_static/BG2_mix
	num    = str(floor(rand_range(1, BALL_amount)))
	scale  = node.scale
	val    = rand_range(scale.x, scale.y * scale_mult)

	path   = "res://assets/graphics/level_bg/BG/BG_"
	node.texture     = load(path+num+".png")
	node.normal_map  = load(path+num+"_n.png")
	node.scale       = Vector2(val, val)


	node   = $"%BG3_detail"
	num    = str(floor(rand_range(1, BG_amount)))
	scale  = node.scale
	val    = rand_range(scale.x * .84, scale.x * scale_mult * .84)

	path   = "res://assets/graphics/level_bg/OLD/BG_"
	node.texture = load(path+num+".png")
	node.scale    = Vector2(val, val)






func _process(dt: float):
	$BG_static/BG_main.rotate   ( .024 * dt)
#	$BG_static/BG2_mix.rotate   (-.016 * dt)
	$"%BG3_detail".rotate(-.018 * dt)






func _input(event: InputEvent):
	if get_parent().allow_board_input:
		if event.is_action_pressed("reload_BG"):
			var i  = get_tree().reload_current_scene()
			print(i)
		elif event.is_action_pressed("change_tile"):
			var theme  = int(floor(rand_range(1, $"../../".theme_data.size())))
			print("tile_theme = "  +str(theme))
			G.SETTINGS.theme  = theme
			G.save_config()
			var _i  = get_tree().reload_current_scene()






func spawn_ball():
	yield(get_tree().create_timer(.2), "timeout")
	var offset := 32
	var TILE   : Node2D  = $"../".board_data[0][0][0][0]
	var sprite : Node2D

	# spawnuje kratki:
	for i in 12:
		var x    := rand_range(offset, G.window.x - offset) - G.window.x/2
		var y    := rand_range(offset, G.window.y - offset) - G.window.y/2
		var BALL :  Node2D = _ball.instance()
		sprite    = BALL.get_node("CollisionShape2D/Sprite")

		BALL.position                = Vector2(x, y)
		BALL.linear_velocity.x       = rand_range(  -4,   4)
		BALL.linear_velocity.y       = rand_range(  -8,   8)
		BALL.angular_velocity        = rand_range(-.12, .12)
		sprite.texture  = TILE.get_node("Sprite").texture
#		var r = rand_range(.2, .3)
#		var g = rand_range(.3, .8)
#		var b = rand_range(.4,  1)

		var s = rand_range(2.6, 8.2)

#		sprite.modulate = Color(r,g,b, .025)
#		var node = ball.get_node("CollisionShape2D/Sprite")
#		ball.get_node("CollisionShape2D")       .scale = Vector2(.02, .02)
		sprite.scale    = Vector2(s, s)
#		sprite.z_index  = -1
		$BG_object/Holder.add_child(BALL)
#		print("object added at: " + str(Vector2(x, y)))


#	# add additional normal maps to BG2
#	for i in 2:
#		var BALL :  Node2D  = _ball.instance()
#		sprite              = BALL.get_node("CollisionShape2D/Sprite")
#
#		$BG_static/BG2_mix.add_child(BALL)
##		yield(get_tree().create_timer(.02), "timeout")
##		sprite.material.blend_mode  = BLEND_MODE_ADD
#
##		BALL.position         = G.window * .5
#		sprite.scale         *= 1.1
#		sprite.self_modulate *= Color(1,1,1, 1)
#
#		var num          = floor(rand_range(1, BALL_amount))
##		var sprite_path  = "res://assets/graphics/level_bg/BG/BG_" + str(num) + ".png"
#		var normal_path  = "res://assets/graphics/level_bg/BG/BG_" + str(num) + "_n.png"
##		print(normal_path)
##		sprite.texture     = load(sprite_path)
##		sprite.texture     = null
#		$BG_static/BG2_mix.normal_map  = load(normal_path)
##		sprite.z_index     = 1






func parr(zoom : float):
	var tween  = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	var i  := 22 * zoom
	tween.tween_property($BG_object, "follow_viewport_scale", i*zoom*.22, .4)
	tween.tween_property($BG_object/Holder, "scale", Vector2(i, i*1.4), .8)
