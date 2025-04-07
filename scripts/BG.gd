extends Node2D


onready var _ball       = preload("res://scenes/BG/BG_object.tscn")
onready var BG1_amount  = $"../../".BG1_amount
onready var BG2_amount  = $"../../".BG2_amount

## BG_transitions/colors stuff:
onready var bg1      := $"%BG_main1"
onready var bg2      := $"%BG_main2"
onready var bg_tween :  SceneTreeTween

export var bg_fade_dur      := 10.0      # in seconds (type:float)






func _ready() -> void:
	BG_init()
	spawn_BG_tiles()

	yield(get_tree().create_timer(.1), "timeout")
	var pos  = get_parent().board_center

	$BG_static.offset  = pos
	$BG_detail.offset  = pos
	$BG_object.offset  = pos






func _process(dt: float) -> void:
	bg1.rotate    (.08 *dt)
	bg2.rotate    (.02 *dt)
	$"%BG_static".rotate  ( .040 *dt)
	$"%BG_detail".rotate  (-.022 *dt)
	$"%Light".rotate      (-.060 *dt)






func _input(event: InputEvent) -> void:
	if get_parent().allow_board_input:
		if event.is_action_pressed("reload_BG"):
			get_tree().call_group("tile", "tweens_disable")  # resets warnings
			yield(get_tree().create_timer(.1), "timeout")
			get_tree().reload_current_scene()

		elif event.is_action_pressed("save_reset"):
			G.save_version  = -1
			G.save_config(true)






func BG_init() -> void:
	var node   :  Sprite
	var bright :  float = G.CONFIG.BG_brightness
	var num    := str(floor(rand_range(1, BG2_amount)))
	var path   := "res://assets/graphics/level_bg/additional/BG_"
	var tween  := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()

	node             = $"%BG_detail"
	node.texture     = load(path+num+".png")
	node.normal_map  = load(path+num+"_n.png")
	node.scale       = Vector2(.1, .1)
	tween.tween_property(node, "modulate:a", .32, 4)

#	node             = $"%BG_static"
#	tween.tween_property(node, "modulate",
#		G.rgb_smooth(BG_color_change(1) *bright *.26, .6), 2)

	bg1.modulate  = BG_color_change(.5, .24)
	bg2.modulate  = BG_color_change(.5, .24)

	BG_fade_cycle(true)






func BG_fade_cycle(init:=false) -> void:
	var bright   : float = G.CONFIG.BG_brightness
	var duration : float = bg_fade_dur *.1 if init else bg_fade_dur

	if bg_tween:
		bg_tween.kill()
	bg_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel()

	bg_tween.tween_property(bg1, "modulate", BG_color_change(0, .4), duration)

	bg_tween.tween_property(bg2, "modulate", BG_color_change(.8, .22), duration)

	bg_tween.tween_property(
		$"%BG_static", "modulate",
		G.rgb_smooth(BG_color_change(.6, .32) *G.CONFIG.BG_brightness *.2, .2), duration *.8)

	bg_tween.chain().tween_callback(self, "BG_swap")






func BG_swap() -> void:
	var temp  := bg1
	var num  := str(floor(rand_range(1, BG1_amount)))
	var path := "res://assets/graphics/level_bg/main/BG_"

	bg1  = bg2
	bg2  = temp
	bg2.texture   = load(path+num+".png")
#	bg2.modulate  = BG_color_change(0, .22)

	BG_fade_cycle()






func BG_color_change(alpha:=1.0, dist:=.16) -> Color:
	var color  : Color = G.CONFIG.BG_color
	var bright : float = clamp(G.CONFIG.BG_brightness, .4, 5)

	dist    *= clamp((bright *.1), .1, .44)
	bright   = rand_range(bright - bright*.25, bright + bright*.2)
	color.r  = rand_range(color.r -dist, color.r +dist) *bright
	color.g  = rand_range(color.g -dist, color.g +dist) *bright
	color.b  = rand_range(color.b -dist, color.b +dist) *bright
	color.a  = alpha

	return color






func spawn_BG_tiles() -> void:
	yield(get_tree().create_timer(1), "timeout")
	var offset := 64
	var TILE   : Node2D  = $"../".board_data[0][0][0][0]
	var sprite : Node2D

	# spawnuje kratki:
	for i in 4:
		var tween := self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		var x     := rand_range(offset, G.window.x -offset) -G.window.x /2
		var y     := rand_range(offset, G.window.y -offset) -G.window.y /2
		var BALL  :  Node2D  = _ball.instance()

		sprite     = BALL.get_node("CollisionShape2D/Sprite")
		var col   := sprite.modulate

		BALL.position                = Vector2(x, y)
		BALL.linear_velocity.x       = rand_range(  -4,   4)
		BALL.linear_velocity.y       = rand_range(  -8,   8)
		BALL.angular_velocity        = rand_range(-.034, .062)

		sprite.texture     = TILE.get_node("Sprite").texture
		sprite.modulate.a  = 0
		tween.tween_property(sprite, "modulate", Color(col.r, col.g, col.b, col.a), 2)

		var s = rand_range(.8, 1.8)
		sprite.scale    = Vector2(sprite.scale.x*s, sprite.scale.y*s)
		$BG_object/Holder.add_child(BALL)






func parr(zoom : float) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	var i     := 6 *zoom

	tween.tween_property(
		$BG_object,        "follow_viewport_scale", $BG_object.scale.x *.6*zoom, 4.42)
	tween.tween_property(
		$BG_object/Holder, "scale",  $BG_object.scale *1.2 *zoom, 8.4)

	tween.tween_property($BG_detail,        "follow_viewport_scale", i* .12,   1.8)
	tween.tween_property($BG_detail/Holder, "scale",  Vector2(i*8.2, i*8.2),   2)
