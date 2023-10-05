extends Node2D


onready var _ball       = preload("res://scenes/BG/BG_object.tscn")
onready var BG1_amount  = $"../../".BG1_amount
onready var BG2_amount  = $"../../".BG2_amount






func _ready() -> void:
	var path  ;  var num : String
	var node  ;  var sca  ;  var val ; var dist
	randomize() ; spawn_ball()

	# BG1 texture is set in Inspector Tab, uses custom shader
	dist   = .16   # (0 - 1)
	val    = G.CONFIG.BG_color

	val.r  = rand_range(val.r - dist, val.r + dist)
	val.g  = rand_range(val.g - dist, val.g + dist)
	val.b  = rand_range(val.b - dist, val.b + dist)
	$"%BG_main".modulate  = val


	node  = $"%BG_detail"
	num   = str(floor(rand_range(1, BG2_amount)))

	path   = "res://assets/graphics/level_bg/additional/BG_"
	node.texture     = load(path+num+".png")
	node.normal_map  = load(path+num+"_n.png")


	node  = $"%BG_overlay"
	num   = str(floor(rand_range(1, BG1_amount)))
	sca   = node.scale
	val   = rand_range(sca.x, sca.x * 1.2)

	path   = "res://assets/graphics/level_bg/main/BG_"
	node.texture     = load(path+num+".png")
	node.scale       = Vector2(val, val)






func _process(dt: float) -> void:
	$"%BG_main".rotate    ( .024 * dt)
	$"%BG_overlay".rotate (-.018 * dt)
	$"%BG_detail".rotate  ( .022 * dt)
	$"%Light".rotate      (-.032 * dt)






func _input(event: InputEvent) -> void:
	if get_parent().allow_board_input:
		if event.is_action_pressed("reload_BG"):
			var _i  = get_tree().reload_current_scene()
		elif event.is_action_pressed("change_tile"):
			var theme  = int(floor(rand_range(1, $"../../".theme_data.size())))
			print("tile_theme = "  +str(theme))
			G.CONFIG.theme  = theme
			G.save_config()
			var _i  = get_tree().reload_current_scene()






func spawn_ball() -> void:
	yield(get_tree().create_timer(1), "timeout")
	var offset := 32
	var TILE   : Node2D  = get_parent().board_data[0][0][0][0]
	var sprite : Node2D

	# spawnuje kratki:
	for i in 4:
		var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		var x     := rand_range(offset, G.window.x - offset) - G.window.x/2
		var y     := rand_range(offset, G.window.y - offset) - G.window.y/2
		var BALL  :  Node2D  = _ball.instance()

		sprite     = BALL.get_node("CollisionShape2D/Sprite")
		var col   := sprite.modulate

		BALL.position                = Vector2(x, y)
		BALL.linear_velocity.x       = rand_range(  -4,   4)
		BALL.linear_velocity.y       = rand_range(  -8,   8)
		BALL.angular_velocity        = rand_range(-.034, .062)

		sprite.texture     = TILE.get_node("Sprite").texture
		sprite.modulate.a  = 0
		tween.tween_property(sprite, "modulate", Color(col.r, col.g, col.b, col.a), 8)

		var s = rand_range(1.2, 3.6)
		sprite.scale    = Vector2(sprite.scale.x*s, sprite.scale.y*s)
		$BG_object/Holder.add_child(BALL)






func variate_color():
	pass






func parr(zoom : float) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	var i     := 6 * zoom

	tween.tween_property($BG_object,        "follow_viewport_scale", i*zoom*.12, 4.72).from_current()
	tween.tween_property($BG_object/Holder, "scale",  $BG_object.scale * 2.6,  16.4)

	tween.tween_property($BG_detail,        "follow_viewport_scale", i* .056,   12.4)
	tween.tween_property($BG_detail/Holder, "scale",  Vector2(-i*3.2, -i*3.2),   2)
